import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AddonOffersService {
    constructor(private prisma: PrismaService) { }

    async getAllActiveOffers() {
        return this.prisma.addonOffer.findMany({
            where: {
                isActive: true,
            },
            orderBy: {
                createdAt: 'desc',
            },
            select: {
                id: true,
                title: true,
                description: true,
                imageUrl: true,
                icon: true,
                price: true,
                category: true,
            },
        });
    }
}
