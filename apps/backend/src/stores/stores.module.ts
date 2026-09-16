import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { DatabaseModule } from '../database/database.module';
import { JwtAuthGuard } from '../common/auth/jwt-auth.guard';
import { StoresController } from './stores.controller';
import { StoresService } from './stores.service';

@Module({
  imports: [DatabaseModule, JwtModule.register({ secret: process.env.JWT_ACCESS_SECRET || 'CHANGE_ME_IN_PRODUCTION' })],
  controllers: [StoresController],
  providers: [StoresService, JwtAuthGuard],
})
export class StoresModule {}
