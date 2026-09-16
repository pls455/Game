import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { IsString, MaxLength, MinLength } from 'class-validator';
import { AuthService } from './auth.service';
import { AuthenticatedRequest, JwtAuthGuard } from '../common/auth/jwt-auth.guard';

class RegisterDto {
  @IsString() @MinLength(7) @MaxLength(20) phone!: string;
  @IsString() @MinLength(6) @MaxLength(128) password!: string;
  @IsString() @MinLength(2) @MaxLength(120) name!: string;
}

class LoginDto {
  @IsString() @MinLength(7) @MaxLength(20) phone!: string;
  @IsString() @MinLength(6) @MaxLength(128) password!: string;
}

class RefreshDto {
  @IsString() @MinLength(20) refreshToken!: string;
}

@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('register') register(@Body() dto: RegisterDto) {
    return this.auth.register(dto.phone, dto.password, dto.name);
  }

  @Post('login') login(@Body() dto: LoginDto) {
    return this.auth.login(dto.phone, dto.password);
  }

  @Post('refresh') refresh(@Body() dto: RefreshDto) {
    return this.auth.refresh(dto.refreshToken);
  }

  @Post('logout')
  @UseGuards(JwtAuthGuard)
  logout(@Req() req: AuthenticatedRequest) {
    return this.auth.logout(req.user!.id);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  me(@Req() req: AuthenticatedRequest) {
    return this.auth.me(req.user!.id);
  }
}
