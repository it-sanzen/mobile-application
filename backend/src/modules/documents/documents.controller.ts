import {
    Controller,
    Get,
    Post,
    Delete,
    Param,
    UseInterceptors,
    UploadedFile,
    Body,
    UseGuards,
    Req,
    Res,
    NotFoundException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { DocumentsService } from './documents.service';
import type { Response } from 'express';
import { diskStorage } from 'multer';
import { extname, join } from 'path';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@Controller('documents')
export class DocumentsController {
    constructor(private readonly documentsService: DocumentsService) { }

    @Post('upload')
    @UseInterceptors(
        FileInterceptor('file', {
            storage: diskStorage({
                destination: './uploads',
                filename: (req, file, callback) => {
                    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
                    callback(null, `${uniqueSuffix}${extname(file.originalname)}`);
                },
            }),
        }),
    )
    async upload(
        @UploadedFile() file: Express.Multer.File,
        @Body('title') title: string,
        @Body('type') type: string,
        @Body('userId') userId: string,
    ) {
        const fileUrl = `/uploads/${file.filename}`;
        return this.documentsService.create({
            title,
            type,
            fileUrl,
            userId,
        });
    }

    @Get()
    async findAll() {
        return this.documentsService.findAll();
    }

    @Get('user/:userId')
    async findByUserId(@Param('userId') userId: string) {
        return this.documentsService.findByUserId(userId);
    }

    @UseGuards(JwtAuthGuard)
    @Get('my')
    async findMyDocuments(@Req() req: any) {
        return this.documentsService.findByUserId(req.user.id);
    }

    @Delete(':id')
    async remove(@Param('id') id: string) {
        return this.documentsService.remove(id);
    }

    @Get(':id/download')
    async download(@Param('id') id: string, @Res() res: Response) {
        console.log(`Download request for ID: ${id}`);
        const document = await this.documentsService.findOne(id);
        if (!document) {
            console.log('Document not found');
            throw new NotFoundException('Document not found');
        }

        console.log(`Document title: ${document.title}`);

        // document.fileUrl is like '/uploads/filename.ext'
        const relativePath = document.fileUrl.startsWith('/')
            ? document.fileUrl.substring(1)
            : document.fileUrl;

        const filePath = join(process.cwd(), relativePath);
        console.log(`File path: ${filePath}`);

        const fileExtension = extname(document.fileUrl);
        const downloadName = `${document.title}${fileExtension}`;
        console.log(`Streaming file as: ${downloadName}`);

        return res.download(filePath, downloadName, (err) => {
            if (err) {
                console.error('Download error:', err);
            }
        });
    }
}
