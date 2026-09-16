import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { DatabaseModule } from '../database/database.module';
import { JwtAuthGuard } from '../common/auth/jwt-auth.guard';
import { CustomersController } from './customers.controller';
import { CustomersService } from './customers.service';

@Module({
  imports: [DatabaseModule, JwtModule.register({ secret: process.env.JWT_ACCESS_SECRET || 'CHANGE_ME_IN_PRODUCTION' })],
  controllers: [CustomersController],
  providers: [CustomersService, JwtAuthGuard],
})
export class CustomersModule {}
