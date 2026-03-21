import { Controller, Post, Get, Delete, Param, Body, UseGuards, UseInterceptors, UploadedFile, Req } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { AiDesignerService } from './ai-designer.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { diskStorage } from 'multer';
import { v4 as uuidv4 } from 'uuid';
import * as path from 'path';

export const storage = {
    storage: diskStorage({
        destination: './uploads/ai-designs',
        filename: (req, file, cb) => {
            const filename: string = path.parse(file.originalname).name.replace(/\s/g, '') + uuidv4();
            const extension: string = path.parse(file.originalname).ext;
            cb(null, `${filename}${extension}`);
        }
    })
};

@Controller('ai-designer')
export class AiDesignerController {
    constructor(private readonly aiDesignerService: AiDesignerService) { }

    @Post('generate-3d')
    @UseGuards(JwtAuthGuard)
    @UseInterceptors(FileInterceptor('image', storage))
    async generate3D(
        @Req() req,
        @UploadedFile() file: Express.Multer.File,
    ) {
        if (!file) {
            throw new Error("An image must be uploaded to generate a 3D object.");
        }

        const sourceImagePath = `./uploads/ai-designs/${file.filename}`;

        return this.aiDesignerService.generate3DObject(
            req.user.userId,
            sourceImagePath
        );
    }

    @Post('generate-3d-from-text')
    async generate3DFromText(
        @Req() req,
        @Body('prompt') prompt: string,
    ) {
        if (!prompt || typeof prompt !== 'string') {
            throw new Error("A text prompt must be provided to generate a 3D object.");
        }

        return this.aiDesignerService.generate3DObjectFromText(
            req.user?.userId || '54f3b7d7-f145-43c0-aa1e-c295025642ee', // Bypass JWT for standalone React testing
            prompt
        );
    }

    @Get('my-designs')
    @UseGuards(JwtAuthGuard)
    async getMyDesigns(@Req() req) {
        return this.aiDesignerService.getMyDesigns(req.user.userId);
    }

    @Delete('my-designs/:id')
    @UseGuards(JwtAuthGuard)
    async deleteDesign(@Req() req, @Param('id') id: string) {
        return this.aiDesignerService.deleteDesign(req.user.userId, id);
    }
}
