import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ShowroomsService } from './showrooms.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminGuard } from '../../auth/guards/admin.guard';
import { CreateShowroomDto } from './dto/create-showroom.dto';

@Controller('showrooms')
export class ShowroomsController {
  constructor(private readonly showroomsService: ShowroomsService) {}

  @Get()
  async findAll(
    @Query('roomType') roomType?: string,
    @Query('style') style?: string,
    @Query('furnishingLevel') furnishingLevel?: string,
  ) {
    return this.showroomsService.findAll({ roomType, style, furnishingLevel });
  }

  @Get('categories')
  async findCategories() {
    return this.showroomsService.findCategories();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.showroomsService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard, AdminGuard)
  async create(@Body() dto: CreateShowroomDto) {
    return this.showroomsService.create(dto);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard, AdminGuard)
  async update(@Param('id') id: string, @Body() dto: Partial<CreateShowroomDto>) {
    return this.showroomsService.update(id, dto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, AdminGuard)
  async softDelete(@Param('id') id: string) {
    return this.showroomsService.softDelete(id);
  }
}
