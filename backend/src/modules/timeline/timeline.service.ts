import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class TimelineService {
    constructor(private prisma: PrismaService) { }

    async getPropertyTimeline(propertyId: string) {
        return this.prisma.timelineMilestone.findMany({
            where: {
                propertyId,
            },
            orderBy: {
                orderIndex: 'asc',
            },
            select: {
                id: true,
                phase: true,
                title: true,
                description: true,
                status: true,
                completedDate: true,
                estimatedDate: true,
                orderIndex: true,
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
}
