import {
    Controller, Get, Post, Patch, Delete,
    Body, Param, Query, UseGuards, UseInterceptors,
    UploadedFile, UploadedFiles,
} from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminGuard } from '../../auth/guards/admin.guard';
import { TimelineService } from './timeline.service';
import { CreateMilestoneUpdateDto, UploadBeforeAfterDto } from './dto/create-milestone-update.dto';

const timelineStorage = diskStorage({
    destination: './uploads/timeline',
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, `timeline-${uniqueSuffix}${extname(file.originalname)}`);
    },
});

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

    // --- New endpoints for construction updates ---

    @Post('milestone/:milestoneId/updates')
    @UseGuards(JwtAuthGuard, AdminGuard)
    @UseInterceptors(FilesInterceptor('photos', 10, { storage: timelineStorage }))
    async createMilestoneUpdate(
        @Param('milestoneId') milestoneId: string,
        @Body() dto: CreateMilestoneUpdateDto,
        @UploadedFiles() photos: Express.Multer.File[],
    ) {
        return this.timelineService.createMilestoneUpdate(milestoneId, dto.notes, photos);
    }

    @Get('milestone/:milestoneId/updates')
    @UseGuards(JwtAuthGuard)
    async getMilestoneUpdates(@Param('milestoneId') milestoneId: string) {
        return this.timelineService.getMilestoneUpdates(milestoneId);
    }

    @Post('milestone/:milestoneId/photos')
    @UseGuards(JwtAuthGuard, AdminGuard)
    @UseInterceptors(FileInterceptor('photo', { storage: timelineStorage }))
    async uploadBeforeAfterPhoto(
        @Param('milestoneId') milestoneId: string,
        @Body() dto: UploadBeforeAfterDto,
        @UploadedFile() photo: Express.Multer.File,
    ) {
        return this.timelineService.uploadBeforeAfterPhoto(milestoneId, photo, dto.photoType, dto.caption);
    }

    @Get(':propertyId/feed')
    @UseGuards(JwtAuthGuard)
    async getUpdateFeed(
        @Param('propertyId') propertyId: string,
        @Query('page') page: string = '1',
        @Query('limit') limit: string = '10',
    ) {
        return this.timelineService.getUpdateFeed(propertyId, parseInt(page), parseInt(limit));
    }

    @Delete('update/:updateId')
    @UseGuards(JwtAuthGuard, AdminGuard)
    async deleteUpdate(@Param('updateId') updateId: string) {
        return this.timelineService.deleteUpdate(updateId);
    }

    @Delete('photo/:photoId')
    @UseGuards(JwtAuthGuard, AdminGuard)
    async deletePhoto(@Param('photoId') photoId: string) {
        return this.timelineService.deletePhoto(photoId);
    }
}
