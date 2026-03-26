import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { CreateChangeRequestDto } from './dto/create-change-request.dto';
import { UpdateChangeRequestDto } from './dto/update-change-request.dto';
import { UpdateChangeRequestStatusDto } from './dto/update-change-request-status.dto';

@Injectable()
export class ChangeRequestsService {
    constructor(
        private prisma: PrismaService,
        private notifications: NotificationsService,
    ) { }

    async create(userId: string, dto: CreateChangeRequestDto) {
        const request = await this.prisma.changeRequest.create({
            data: {
                userId,
                propertyId: dto.propertyId,
                title: dto.title,
                description: dto.description,
                category: dto.category,
            },
            include: {
                property: { select: { id: true, name: true, location: true } },
            },
        });

        return request;
    }

    async getMyRequests(userId: string) {
        return this.prisma.changeRequest.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            include: {
                property: { select: { id: true, name: true, location: true } },
            },
        });
    }

    async update(id: string, userId: string, dto: UpdateChangeRequestDto) {
        const request = await this.prisma.changeRequest.findUnique({ where: { id } });
        if (!request) {
            throw new NotFoundException('Change request not found');
        }
        if (request.userId !== userId) {
            throw new NotFoundException('Change request not found');
        }
        // Only allow editing if status is SUBMITTED
        if (request.status !== 'SUBMITTED') {
            throw new NotFoundException('Cannot edit a request that is already under review or processed');
        }

        return this.prisma.changeRequest.update({
            where: { id },
            data: {
                ...(dto.title && { title: dto.title }),
                ...(dto.description && { description: dto.description }),
                ...(dto.category && { category: dto.category }),
            },
            include: {
                property: { select: { id: true, name: true, location: true } },
            },
        });
    }

    async getById(id: string) {
        const request = await this.prisma.changeRequest.findUnique({
            where: { id },
            include: {
                property: { select: { id: true, name: true, location: true } },
                user: { select: { id: true, name: true, email: true } },
            },
        });

        if (!request) {
            throw new NotFoundException('Change request not found');
        }

        return request;
    }

    async updateStatus(id: string, dto: UpdateChangeRequestStatusDto) {
        const request = await this.prisma.changeRequest.findUnique({ where: { id } });
        if (!request) {
            throw new NotFoundException('Change request not found');
        }

        const updated = await this.prisma.changeRequest.update({
            where: { id },
            data: {
                status: dto.status,
                adminNotes: dto.adminNotes,
                costImpact: dto.costImpact,
                timelineImpact: dto.timelineImpact,
            },
            include: {
                property: { select: { id: true, name: true, location: true } },
            },
        });

        // Notify user about status change
        const statusText = dto.status === 'APPROVED' ? 'approved' : dto.status === 'REJECTED' ? 'rejected' : 'updated';
        await this.notifications.createNotification({
            userId: request.userId,
            title: `Change Request ${statusText}`,
            message: `Your change request "${request.title}" has been ${statusText}.${dto.adminNotes ? ' Notes: ' + dto.adminNotes : ''}`,
            type: 'CHANGE_REQUEST',
            relatedEntityId: id,
        });

        return updated;
    }

    async getAllForAdmin() {
        return this.prisma.changeRequest.findMany({
            orderBy: { createdAt: 'desc' },
            include: {
                property: { select: { id: true, name: true, location: true } },
                user: { select: { id: true, name: true, email: true } },
            },
        });
    }
}
