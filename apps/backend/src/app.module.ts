import { Controller, Get, Module } from '@nestjs/common';
import { DatabaseModule } from './database/database.module';
import { AuthModule } from './auth/auth.module';
import { StoresModule } from './stores/stores.module';
import { CustomersModule } from './customers/customers.module';

@Controller()
export class AppController {
  @Get('health')
  health() {
    return { ok: true, service: 'dakkana-api', version: 'v1' };
  }
}

@Module({
  imports: [DatabaseModule, AuthModule, StoresModule, CustomersModule],
  controllers: [AppController],
})
export class AppModule {}
