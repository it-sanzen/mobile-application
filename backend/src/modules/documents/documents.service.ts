import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { existsSync } from 'fs';
import { join } from 'path';

@Injectable()
export class DocumentsService {
    constructor(
        private prisma: PrismaService,
        private notificationsService: NotificationsService
    ) { }

    async create(data: { title: string; type: string; fileUrl: string; userId: string }) {
        const doc = await this.prisma.document.create({
            data,
        });

        // Trigger Notification
        await this.notificationsService.createNotification({
            userId: data.userId,
            title: 'New Document Uploaded',
            message: `A new ${data.type} document "${data.title}" has been uploaded to your profile.`,
            type: 'DOCUMENT',
            relatedEntityId: doc.id,
        });

        return doc;
    }

    async findAll() {
        return this.prisma.document.findMany({
            include: {
                user: {
                    select: {
                        name: true,
                        email: true,
                    },
                },
            },
        });
    }

    async findByUserId(userId: string) {
        const documents = await this.prisma.document.findMany({
            where: { userId },
        });

        // Only return documents whose files actually exist on disk
        return documents.filter(doc => {
            if (!doc.fileUrl) return false;
            const relativePath = doc.fileUrl.startsWith('/')
                ? doc.fileUrl.substring(1)
                : doc.fileUrl;
            const filePath = join(process.cwd(), relativePath);
            return existsSync(filePath);
        });
    }

    async findOne(id: string) {
        return this.prisma.document.findUnique({
            where: { id },
        });
    }

    async remove(id: string) {
        return this.prisma.document.delete({
            where: { id },
        });
    }
}
