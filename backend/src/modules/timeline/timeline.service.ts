import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class TimelineService {
    private readonly logger = new Logger(TimelineService.name);

    constructor(
        private prisma: PrismaService,
        private notificationsService: NotificationsService,
    ) { }

    async getPropertyTimeline(propertyId: string) {
        return this.prisma.timelineMilestone.findMany({
            where: { propertyId },
            orderBy: { orderIndex: 'asc' },
            include: {
                updates: {
                    orderBy: { createdAt: 'desc' },
                    take: 3,
                    include: { photos: true },
                },
                photos: {
                    where: { milestoneUpdateId: null },
                    orderBy: { createdAt: 'asc' },
                },
            },
        });
    }

    async create(propertyId: string, data: any) {
        return this.prisma.timelineMilestone.create({
            data: {
                ...data,
                propertyId,
            },
        });
    }

    async update(id: string, data: any) {
        return this.prisma.timelineMilestone.update({
            where: { id },
            data,
        });
    }

    async remove(id: string) {
        return this.prisma.timelineMilestone.delete({
            where: { id },
        });
    }

    async createMilestoneUpdate(milestoneId: string, notes: string, photoFiles: Express.Multer.File[]) {
        const milestone = await this.prisma.timelineMilestone.findUnique({
            where: { id: milestoneId },
            select: { id: true, propertyId: true, phase: true, title: true },
        });
        if (!milestone) throw new NotFoundException('Milestone not found');

        const update = await this.prisma.milestoneUpdate.create({
            data: {
                milestoneId,
                notes,
                photos: {
                    create: (photoFiles || []).map(file => ({
                        milestoneId,
                        photoUrl: `/uploads/timeline/${file.filename}`,
                        photoType: 'PROGRESS' as const,
                    })),
                },
            },
            include: { photos: true },
        });

        // Notify all buyers of this property
        try {
            const userProperties = await this.prisma.userProperty.findMany({
                where: { propertyId: milestone.propertyId },
                select: { userId: true },
            });

            for (const up of userProperties) {
                await this.notificationsService.createNotification({
                    userId: up.userId,
                    title: 'Construction Update',
                    message: `${milestone.phase}: ${milestone.title} — ${notes}`,
                    type: 'CONSTRUCTION',
                    relatedEntityId: milestoneId,
                });
            }
        } catch (err) {
            this.logger.error('Failed to send construction notifications', err);
        }

        return update;
    }

    async getMilestoneUpdates(milestoneId: string) {
        return this.prisma.milestoneUpdate.findMany({
            where: { milestoneId },
            orderBy: { createdAt: 'desc' },
            include: { photos: true },
        });
    }

    async uploadBeforeAfterPhoto(milestoneId: string, file: Express.Multer.File, photoType: string, caption?: string) {
        const milestone = await this.prisma.timelineMilestone.findUnique({ where: { id: milestoneId } });
        if (!milestone) throw new NotFoundException('Milestone not found');

        return this.prisma.milestonePhoto.create({
            data: {
                milestoneId,
                photoUrl: `/uploads/timeline/${file.filename}`,
                photoType: photoType as any,
                caption,
            },
        });
    }

    async getUpdateFeed(propertyId: string, page: number = 1, limit: number = 10) {
        const skip = (page - 1) * limit;

        const [data, total] = await Promise.all([
            this.prisma.milestoneUpdate.findMany({
                where: {
                    milestone: { propertyId },
                },
                orderBy: { createdAt: 'desc' },
                skip,
                take: limit,
                include: {
                    photos: true,
                    milestone: {
                        select: { id: true, phase: true, title: true },
                    },
                },
            }),
            this.prisma.milestoneUpdate.count({
                where: { milestone: { propertyId } },
            }),
        ]);

        return { data, total, page, limit };
    }

    async deleteUpdate(updateId: string) {
        return this.prisma.milestoneUpdate.delete({ where: { id: updateId } });
    }

    async deletePhoto(photoId: string) {
        return this.prisma.milestonePhoto.delete({ where: { id: photoId } });
    }
}
