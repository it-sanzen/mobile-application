import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { CompanyNewsService } from './company-news.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminGuard } from '../../auth/guards/admin.guard';

@Controller('company-news')
export class CompanyNewsController {
    constructor(private readonly companyNewsService: CompanyNewsService) { }

    @Get()
    @UseGuards(JwtAuthGuard)
    async getAllNews() {
        return this.companyNewsService.findAll();
    }

    @Post()
    @UseGuards(JwtAuthGuard, AdminGuard)
    async createNews(@Body() data: any) {
        return this.companyNewsService.create(data);
    }

    @Put(':id')
    @UseGuards(JwtAuthGuard, AdminGuard)
    async updateNews(@Param('id') id: string, @Body() data: any) {
        return this.companyNewsService.update(id, data);
    }

    @Delete(':id')
    @UseGuards(JwtAuthGuard, AdminGuard)
    async deleteNews(@Param('id') id: string) {
        return this.companyNewsService.remove(id);
    }
}
