import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, Req, Query } from '@nestjs/common';
import { PropertiesService } from './properties.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminGuard } from '../../auth/guards/admin.guard';
import { CreatePropertyDto } from './dto/create-property.dto';
import { UpdatePropertyDto } from './dto/update-property.dto';

@Controller('properties')
export class PropertiesController {
    constructor(private readonly propertiesService: PropertiesService) { }

    @Get('my-primary')
    @UseGuards(JwtAuthGuard)
    async getMyPrimaryProperty(@Req() req: any) {
        return this.propertiesService.getUserPrimaryProperty(req.user.userId);
    }

    @Get('my')
    @UseGuards(JwtAuthGuard)
    async getMyProperties(@Req() req: any, @Query('propertyType') propertyType?: string) {
        return this.propertiesService.getUserProperties(req.user.userId, propertyType);
    }

    @Get('all')
    @UseGuards(JwtAuthGuard, AdminGuard)
    async getAllProperties() {
        return this.propertiesService.getAllProperties();
    }

    @Post()
    @UseGuards(JwtAuthGuard, AdminGuard)
    async createProperty(@Body() createPropertyDto: CreatePropertyDto) {
        return this.propertiesService.createProperty(createPropertyDto);
    }

    @Put(':id')
    @UseGuards(JwtAuthGuard, AdminGuard)
    async updateProperty(@Param('id') id: string, @Body() updatePropertyDto: UpdatePropertyDto) {
        return this.propertiesService.updateProperty(id, updatePropertyDto);
    }

    @Delete(':id')
    @UseGuards(JwtAuthGuard, AdminGuard)
    async deleteProperty(@Param('id') id: string) {
        return this.propertiesService.deleteProperty(id);
    }
}
