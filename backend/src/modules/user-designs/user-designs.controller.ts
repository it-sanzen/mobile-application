import { Controller, Get, Post, Put, Delete, Param, Body, Req, UseGuards, UseInterceptors, UploadedFile } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import * as path from 'path';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { UserDesignsService } from './user-designs.service';
import { CreateUserDesignDto } from './dto/create-user-design.dto';
import { SaveDesignItemsDto } from './dto/save-design-items.dto';

@Controller('user-designs')
export class UserDesignsController {
    constructor(private readonly userDesignsService: UserDesignsService) { }

    @Get()
    @UseGuards(JwtAuthGuard)
    async findAll(@Req() req: any) {
        return this.userDesignsService.findAllByUser(req.user.userId);
    }

    @Post()
    @UseGuards(JwtAuthGuard)
    async create(@Req() req: any, @Body() dto: CreateUserDesignDto) {
        return this.userDesignsService.create(req.user.userId, dto);
    }

    @Post(':id/screenshot')
    @UseGuards(JwtAuthGuard)
    @UseInterceptors(FileInterceptor('screenshot', {
        storage: diskStorage({
            destination: './uploads/designs/screenshots',
            filename: (req, file, cb) => {
                const timestamp = Date.now();
                const ext = path.parse(file.originalname).ext;
                cb(null, `screenshot-${timestamp}${ext}`);
            },
        }),
    }))
    async uploadScreenshot(
        @Param('id') id: string,
        @Req() req: any,
        @UploadedFile() file: Express.Multer.File,
    ) {
        return this.userDesignsService.uploadScreenshot(id, req.user.userId, file);
    }

    @Put(':id/items')
    @UseGuards(JwtAuthGuard)
    async updateItems(
        @Param('id') id: string,
        @Req() req: any,
        @Body() dto: SaveDesignItemsDto,
    ) {
        return this.userDesignsService.updateItems(id, req.user.userId, dto.items);
    }

    @Put(':id')
    @UseGuards(JwtAuthGuard)
    async update(
        @Param('id') id: string,
        @Req() req: any,
        @Body() body: { name?: string; thumbnailUrl?: string; sceneState?: any },
    ) {
        return this.userDesignsService.update(id, req.user.userId, body);
    }

    @Get(':id')
    @UseGuards(JwtAuthGuard)
    async findOne(@Param('id') id: string, @Req() req: any) {
        return this.userDesignsService.findOne(id, req.user.userId);
    }

    @Delete(':id')
    @UseGuards(JwtAuthGuard)
    async remove(@Param('id') id: string, @Req() req: any) {
        return this.userDesignsService.remove(id, req.user.userId);
    }
}
