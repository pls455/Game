import { Module } from '@nestjs/common';
import { DatabaseModule } from './database/database.module';
import { AuthModule } from './auth/auth.module';
import { Controller, Get } from '@nestjs/common';

@Controller()
export class AppController {
  @Get('health')
  health() { return { ok: true, service: 'dakkana-api', version: 'v1' }; }
}

@Module({ imports: [DatabaseModule, AuthModule], controllers: [AppController] })
export class AppModule {}
