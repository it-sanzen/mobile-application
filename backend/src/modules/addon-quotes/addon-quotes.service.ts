import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { CreateAddonQuoteDto } from './dto/create-addon-quote.dto';
import { UpdateAddonQuoteStatusDto } from './dto/update-addon-quote-status.dto';

@Injectable()
export class AddonQuotesService {
    constructor(
        private prisma: PrismaService,
        private notifications: NotificationsService,
    ) { }

    async create(userId: string, dto: CreateAddonQuoteDto) {
        // Fetch addon offers to get prices
        const addons = await this.prisma.addonOffer.findMany({
            where: { id: { in: dto.addonOfferIds }, isActive: true },
        });

        if (addons.length === 0) {
            throw new NotFoundException('No valid addon offers found');
        }

        const totalPrice = addons.reduce((sum, a) => sum + (a.price || 0), 0);

        const quote = await this.prisma.addonQuote.create({
            data: {
                userId,
                propertyId: dto.propertyId,
                totalPrice,
                items: {
                    create: addons.map(a => ({
                        addonOfferId: a.id,
                        price: a.price || 0,
                    })),
                },
            },
            include: {
                items: { include: { addonOffer: true } },
                property: { select: { id: true, name: true, location: true } },
            },
        });

        return quote;
    }

    async getMyQuotes(userId: string) {
        return this.prisma.addonQuote.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            include: {
                items: { include: { addonOffer: true } },
                property: { select: { id: true, name: true, location: true } },
            },
        });
    }

    async getById(id: string) {
        const quote = await this.prisma.addonQuote.findUnique({
            where: { id },
            include: {
                items: { include: { addonOffer: true } },
                property: { select: { id: true, name: true, location: true } },
                user: { select: { id: true, name: true, email: true, phone: true } },
            },
        });
        if (!quote) throw new NotFoundException('Quote not found');
        return quote;
    }

    async getAllForAdmin() {
        return this.prisma.addonQuote.findMany({
            orderBy: { createdAt: 'desc' },
            include: {
                items: { include: { addonOffer: true } },
                property: { select: { id: true, name: true, location: true } },
                user: { select: { id: true, name: true, email: true, phone: true } },
            },
        });
    }

    async updateStatus(id: string, dto: UpdateAddonQuoteStatusDto) {
        const quote = await this.prisma.addonQuote.findUnique({ where: { id } });
        if (!quote) throw new NotFoundException('Quote not found');

        const updated = await this.prisma.addonQuote.update({
            where: { id },
            data: {
                status: dto.status,
                adminNotes: dto.adminNotes,
            },
            include: {
                items: { include: { addonOffer: true } },
                property: { select: { id: true, name: true, location: true } },
            },
        });

        const statusText = dto.status === 'APPROVED' ? 'approved' : dto.status === 'REJECTED' ? 'rejected' : 'updated';
        await this.notifications.createNotification({
            userId: quote.userId,
            title: `Add-on Quote ${statusText}`,
            message: `Your add-on quote has been ${statusText}.${dto.adminNotes ? ' Notes: ' + dto.adminNotes : ''}`,
            type: 'SYSTEM',
            relatedEntityId: id,
        });

        return updated;
    }
}
