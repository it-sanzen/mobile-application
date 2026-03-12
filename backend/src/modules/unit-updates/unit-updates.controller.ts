import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, Req } from '@nestjs/common';
import { UnitUpdatesService } from './unit-updates.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminGuard } from '../../auth/guards/admin.guard';

@Controller('unit-updates')
export class UnitUpdatesController {
    constructor(private readonly unitUpdatesService: UnitUpdatesService) { }

    @Get()
    @UseGuards(JwtAuthGuard)
    async getUserUpdates(@Req() req: any) {
        return this.unitUpdatesService.findByUserId(req.user.userId);
    }

    @Post()
    @UseGuards(JwtAuthGuard, AdminGuard)
    async createUpdate(@Body() data: any) {
        return this.unitUpdatesService.create(data);
    }

    @Put(':id')
    @UseGuards(JwtAuthGuard, AdminGuard)
    async updateUpdate(@Param('id') id: string, @Body() data: any) {
        return this.unitUpdatesService.update(id, data);
    }

    @Delete(':id')
    @UseGuards(JwtAuthGuard, AdminGuard)
    async deleteUpdate(@Param('id') id: string) {
        return this.unitUpdatesService.remove(id);
    }
}
