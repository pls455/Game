import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { DatabaseModule } from '../database/database.module';
import { JwtAuthGuard } from '../common/auth/jwt-auth.guard';

@Module({
  imports: [DatabaseModule, JwtModule.register({ secret: process.env.JWT_ACCESS_SECRET || 'CHANGE_ME_IN_PRODUCTION', signOptions: { expiresIn: '15m' } })],
  controllers: [AuthController],
  providers: [AuthService, JwtAuthGuard],
})
export class AuthModule {}
