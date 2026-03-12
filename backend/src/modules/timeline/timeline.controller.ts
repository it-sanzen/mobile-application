import { Controller, Get, Post, Patch, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminGuard } from '../../auth/guards/admin.guard';
import { TimelineService } from './timeline.service';

@Controller('timeline')
export class TimelineController {
    constructor(private readonly timelineService: TimelineService) { }

    @Get(':propertyId')
    @UseGuards(JwtAuthGuard)
    async getPropertyTimeline(@Param('propertyId') propertyId: string) {
        return this.timelineService.getPropertyTimeline(propertyId);
    }

    @Post(':propertyId')
    @UseGuards(JwtAuthGuard, AdminGuard)
    async createMilestone(@Param('propertyId') propertyId: string, @Body() data: any) {
        return this.timelineService.create(propertyId, data);
    }

    @Patch('milestone/:id')
    @UseGuards(JwtAuthGuard, AdminGuard)
    async updateMilestone(@Param('id') id: string, @Body() data: any) {
        return this.timelineService.update(id, data);
    }

    @Delete('milestone/:id')
    @UseGuards(JwtAuthGuard, AdminGuard)
    async deleteMilestone(@Param('id') id: string) {
        return this.timelineService.remove(id);
    }
}
