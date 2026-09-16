import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { randomUUID, createHash } from 'crypto';
import { DatabaseService } from '../database/database.service';

@Injectable()
export class AuthService {
  constructor(private readonly db: DatabaseService, private readonly jwt: JwtService) {}

  async register(email: string, password: string, fullName: string) {
    const passwordHash = await bcrypt.hash(password, 12);
    const id = randomUUID();
    try {
      const result = await this.db.query(
        `INSERT INTO users (id,email,password_hash,full_name) VALUES ($1,$2,$3,$4) RETURNING id,email,full_name,created_at`,
        [id, email.trim().toLowerCase(), passwordHash, fullName.trim()],
      );
      return this.issueTokens(result.rows[0]);
    } catch (error) {
      if ((error as { code?: string }).code === '23505') throw new UnauthorizedException('البريد مستخدم مسبقًا');
      throw error;
    }
  }

  async login(email: string, password: string) {
    const result = await this.db.query(`SELECT id,email,full_name,password_hash FROM users WHERE email=$1 AND is_active=true`, [email.trim().toLowerCase()]);
    const user = result.rows[0];
    if (!user || !(await bcrypt.compare(password, user.password_hash))) throw new UnauthorizedException('بيانات الدخول غير صحيحة');
    return this.issueTokens(user);
  }

  async refresh(refreshToken: string) {
    const hash = createHash('sha256').update(refreshToken).digest('hex');
    const result = await this.db.query(`SELECT u.id,u.email,u.full_name FROM refresh_tokens r JOIN users u ON u.id=r.user_id WHERE r.token_hash=$1 AND r.revoked_at IS NULL AND r.expires_at>now() AND u.is_active=true`, [hash]);
    if (!result.rows[0]) throw new UnauthorizedException('جلسة الدخول منتهية');
    await this.db.query(`UPDATE refresh_tokens SET revoked_at=now() WHERE token_hash=$1`, [hash]);
    return this.issueTokens(result.rows[0]);
  }

  private async issueTokens(user: { id: string; email: string; full_name: string }) {
    const accessToken = await this.jwt.signAsync({ sub: user.id, email: user.email });
    const refreshToken = randomUUID() + randomUUID();
    const hash = createHash('sha256').update(refreshToken).digest('hex');
    await this.db.query(`INSERT INTO refresh_tokens (user_id,token_hash,expires_at) VALUES ($1,$2,now()+interval '30 days')`, [user.id, hash]);
    return { accessToken, refreshToken, user: { id: user.id, email: user.email, fullName: user.full_name } };
  }
}
