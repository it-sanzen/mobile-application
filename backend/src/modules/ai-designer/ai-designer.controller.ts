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

    @Post('generate')
    @UseGuards(JwtAuthGuard)
    @UseInterceptors(FileInterceptor('image', storage))
    async generateDesign(
        @Req() req,
        @UploadedFile() file: Express.Multer.File,
        @Body() body: { roomType: string; designStyle: string; shouldMock?: string }
    ) {
        // Construct the URL where this file can be accessed publicly 
        // (Assuming the backend serves the /uploads directory statically)
        const baseUrl = process.env.BACKEND_URL || `http://${req.headers.host}`;
        const sourceImageUrl = `${baseUrl}/uploads/ai-designs/${file.filename}`;

        const isMocking = body.shouldMock === 'true' || true; // Force mock for now

        return this.aiDesignerService.generateDesign(
            req.user.userId,
            sourceImageUrl,
            body.roomType,
            body.designStyle,
            isMocking
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
