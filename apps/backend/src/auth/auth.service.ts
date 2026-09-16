import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { createHash, randomUUID } from 'crypto';
import { DatabaseService } from '../database/database.service';

type TokenUser = { id: string; phone: string; name: string };
type LoginUser = TokenUser & { password_hash: string };

@Injectable()
export class AuthService {
  constructor(private readonly db: DatabaseService, private readonly jwt: JwtService) {}

  async register(phone: string, password: string, name: string) {
    const normalizedPhone = phone.trim();
    const passwordHash = await bcrypt.hash(password, 12);
    const id = randomUUID();
    try {
      const result = await this.db.query(
        `INSERT INTO users (id,name,phone,password_hash) VALUES ($1,$2,$3,$4) RETURNING id,phone,name,created_at`,
        [id, name.trim(), normalizedPhone, passwordHash],
      );
      return this.issueTokens(result.rows[0] as TokenUser);
    } catch (error) {
      if ((error as { code?: string }).code === '23505') {
        throw new UnauthorizedException('رقم الجوال مستخدم مسبقًا');
      }
      throw error;
    }
  }

  async login(phone: string, password: string) {
    const result = await this.db.query(
      `SELECT id,phone,name,password_hash FROM users WHERE phone=$1 AND deleted_at IS NULL`,
      [phone.trim()],
    );
    const user = result.rows[0] as LoginUser | undefined;
    if (!user || !(await bcrypt.compare(password, user.password_hash))) {
      throw new UnauthorizedException('بيانات الدخول غير صحيحة');
    }
    return this.issueTokens(user);
  }

  async refresh(refreshToken: string) {
    const hash = createHash('sha256').update(refreshToken).digest('hex');
    const result = await this.db.query(
      `SELECT u.id,u.phone,u.name FROM refresh_tokens r JOIN users u ON u.id=r.user_id WHERE r.token_hash=$1 AND r.revoked_at IS NULL AND r.expires_at>now() AND u.deleted_at IS NULL`,
      [hash],
    );
    const user = result.rows[0] as TokenUser | undefined;
    if (!user) throw new UnauthorizedException('جلسة الدخول منتهية');
    await this.db.query(`UPDATE refresh_tokens SET revoked_at=now() WHERE token_hash=$1`, [hash]);
    return this.issueTokens(user);
  }

  async logout(userId: string) {
    await this.db.query(`UPDATE refresh_tokens SET revoked_at=now() WHERE user_id=$1 AND revoked_at IS NULL`, [userId]);
    return { ok: true };
  }

  async me(userId: string) {
    const user = await this.db.query(`SELECT id,name,phone,created_at,updated_at FROM users WHERE id=$1 AND deleted_at IS NULL`, [userId]);
    if (!user.rowCount) throw new UnauthorizedException('المستخدم غير موجود');
    const stores = await this.db.query(
      `SELECT s.id,s.name,s.phone,s.address,s.currency,su.role FROM stores s JOIN store_users su ON su.store_id=s.id WHERE su.user_id=$1 AND s.deleted_at IS NULL ORDER BY s.created_at`,
      [userId],
    );
    return { user: user.rows[0], stores: stores.rows };
  }

  private async issueTokens(user: TokenUser) {
    const accessToken = await this.jwt.signAsync({ sub: user.id, phone: user.phone });
    const refreshToken = randomUUID() + randomUUID();
    const hash = createHash('sha256').update(refreshToken).digest('hex');
    await this.db.query(
      `INSERT INTO refresh_tokens (user_id,token_hash,expires_at) VALUES ($1,$2,now()+interval '30 days')`,
      [user.id, hash],
    );
    return {
      accessToken,
      refreshToken,
      user: { id: user.id, phone: user.phone, name: user.name },
    };
  }
}
