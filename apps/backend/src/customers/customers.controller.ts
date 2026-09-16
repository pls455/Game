import { Body, Controller, Get, Param, Post, Put, Query, Req, UseGuards } from '@nestjs/common';
import { IsNumber, IsOptional, IsString, Max, MaxLength, Min, MinLength } from 'class-validator';
import { AuthenticatedRequest, JwtAuthGuard } from '../common/auth/jwt-auth.guard';
import { CustomersService } from './customers.service';

class CustomerDto {
  @IsString() @MinLength(2) @MaxLength(120) name!: string;
  @IsOptional() @IsString() @MaxLength(30) phone?: string;
  @IsOptional() @IsString() @MaxLength(200) address?: string;
  @IsOptional() @IsString() @MaxLength(500) notes?: string;
  @IsOptional() @IsNumber() openingBalance?: number;
}

@Controller('customers')
@UseGuards(JwtAuthGuard)
export class CustomersController {
  constructor(private readonly customers: CustomersService) {}

  @Get()
  list(@Req() req: AuthenticatedRequest, @Query('search') search?: string, @Query('limit') limit?: string) {
    return this.customers.list(req.user!.id, search || '', Math.min(Number(limit || 30), 50));
  }

  @Post()
  create(@Req() req: AuthenticatedRequest, @Body() dto: CustomerDto) {
    return this.customers.create(req.user!.id, dto);
  }

  @Get(':id')
  get(@Req() req: AuthenticatedRequest, @Param('id') id: string) {
    return this.customers.get(req.user!.id, id);
  }

  @Put(':id')
  update(@Req() req: AuthenticatedRequest, @Param('id') id: string, @Body() dto: CustomerDto) {
    return this.customers.update(req.user!.id, id, dto);
  }

  @Get(':id/statement')
  statement(@Req() req: AuthenticatedRequest, @Param('id') id: string) {
    return this.customers.statement(req.user!.id, id);
  }
}
