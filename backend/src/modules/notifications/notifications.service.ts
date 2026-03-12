import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsGateway } from './notifications.gateway';


@Injectable()
export class NotificationsService {
    private readonly logger = new Logger(NotificationsService.name);

    constructor(
        private readonly prisma: PrismaService,
        private readonly gateway: NotificationsGateway,
    ) { }

    /**
     * Main entrypoint to create a notification. 
     * It logs to DB for Inbox history and fires a real-time socket.
     */
    async createNotification(data: {
        userId: string;
        title: string;
        message: string;
        type: any;
        relatedEntityId?: string;
    }) {
        try {
            // 1. Save to Database
            const notification = await this.prisma.notification.create({
                data: {
                    userId: data.userId,
                    title: data.title,
                    message: data.message,
                    type: data.type,
                    relatedEntityId: data.relatedEntityId,
                },
            });

            // 2. Emit WebSocket for instant delivery to active devices
            this.gateway.notifyUser(data.userId, {
                id: notification.id,
                title: notification.title,
                message: notification.message,
                type: notification.type,
                relatedEntityId: notification.relatedEntityId,
                createdAt: notification.createdAt,
            });

            return notification;
        } catch (error) {
            this.logger.error('Failed to create persistent notification', error);
            throw error;
        }
    }

    async getUserNotifications(userId: string) {
        return this.prisma.notification.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            take: 50, // Keep list sane
        });
    }

    async markAsRead(notificationId: string, userId: string) {
        return this.prisma.notification.updateMany({
            where: { id: notificationId, userId },
            data: { isRead: true },
        });
    }

    async markAllAsRead(userId: string) {
        return this.prisma.notification.updateMany({
            where: { userId, isRead: false },
            data: { isRead: true },
        });
    }
}
