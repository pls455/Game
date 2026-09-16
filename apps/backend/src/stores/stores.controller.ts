import { Body, Controller, Get, Post, Put, Req, UseGuards } from '@nestjs/common';
import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';
import { JwtAuthGuard, AuthenticatedRequest } from '../common/auth/jwt-auth.guard';
import { StoresService } from './stores.service';

class CreateStoreDto {
  @IsString() @MinLength(2) @MaxLength(120) name!: string;
  @IsOptional() @IsString() @MaxLength(30) phone?: string;
  @IsOptional() @IsString() @MaxLength(200) address?: string;
  @IsOptional() @IsString() @MaxLength(8) currency?: string;
}

class UpdateStoreDto extends CreateStoreDto {}

@Controller('store')
@UseGuards(JwtAuthGuard)
export class StoresController {
  constructor(private readonly stores: StoresService) {}

  @Post()
  create(@Req() req: AuthenticatedRequest, @Body() dto: CreateStoreDto) {
    return this.stores.create(req.user!.id, dto);
  }

  @Get()
  get(@Req() req: AuthenticatedRequest) {
    return this.stores.getForUser(req.user!.id);
  }

  @Put()
  update(@Req() req: AuthenticatedRequest, @Body() dto: UpdateStoreDto) {
    return this.stores.updateForUser(req.user!.id, dto);
  }
}
