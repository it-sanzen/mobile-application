import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class UnitUpdatesService {
    constructor(
        private prisma: PrismaService,
        private notificationsService: NotificationsService
    ) { }

    async create(data: { userId: string, updateType: any, title: string, description: string, time: string, isPublished: boolean }) {
        const update = await this.prisma.unitUpdate.create({
            data,
        });

        if (update.isPublished) {
            await this.notificationsService.createNotification({
                userId: update.userId,
                title: 'New Unit Update',
                message: update.title,
                type: 'UNIT_UPDATE',
                relatedEntityId: update.id,
            });
        }

        return update;
    }

    async findByUserId(userId: string) {
        return this.prisma.unitUpdate.findMany({
            where: {
                userId,
                isPublished: true,
            },
            orderBy: {
                publishedAt: 'desc',
            },
            select: {
                id: true,
                updateType: true,
                title: true,
                description: true,
                time: true,
                publishedAt: true,
                isPublished: true,
            },
        });
    }

    async update(id: string, data: any) {
        return this.prisma.unitUpdate.update({
            where: { id },
            data,
        });
    }

    async remove(id: string) {
        return this.prisma.unitUpdate.delete({
            where: { id },
        });
    }
}
