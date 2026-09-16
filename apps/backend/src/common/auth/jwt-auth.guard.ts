import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

export type AuthenticatedRequest = Request & {
  user?: { id: string; phone: string; storeId?: string; role?: string };
};

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly jwt: JwtService) {}

  async canActivate(context: ExecutionContext) {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const header = request.headers.get('authorization');
    const token = header?.startsWith('Bearer ') ? header.slice(7) : undefined;
    if (!token) throw new UnauthorizedException('يلزم تسجيل الدخول');

    try {
      const payload = await this.jwt.verifyAsync<{ sub: string; phone: string }>(token);
      request.user = { id: payload.sub, phone: payload.phone };
      return true;
    } catch {
      throw new UnauthorizedException('جلسة الدخول غير صالحة');
    }
  }
}
