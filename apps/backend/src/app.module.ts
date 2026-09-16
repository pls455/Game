import { Module } from '@nestjs/common';
import { Controller, Get } from '@nestjs/common';

@Controller('api/v1')
export class AppController {
  @Get('health')
  health() { return { ok: true, service: 'dakkana-api', version: 'v1' }; }
}

@Module({ controllers: [AppController] })
export class AppModule {}
