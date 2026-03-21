import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class WishlistService {
    constructor(private prisma: PrismaService) { }

    async generateFromDesign(designId: string, userId: string) {
        const design = await this.prisma.userDesign.findUnique({
            where: { id: designId },
            include: { items: true },
        });

        if (!design) {
            throw new NotFoundException('Design not found');
        }

        if (design.userId !== userId) {
            throw new ForbiddenException('You do not have access to this design');
        }

        // Group items by productId and count occurrences
        const productCounts = new Map<string, number>();
        for (const item of design.items) {
            const current = productCounts.get(item.productId) || 0;
            productCounts.set(item.productId, current + 1);
        }

        // Upsert wishlist and items in a transaction
        return this.prisma.$transaction(async (tx) => {
            const wishlist = await tx.wishlist.upsert({
                where: { designId },
                create: {
                    designId,
                    userId,
                },
                update: {
                    updatedAt: new Date(),
                },
            });

            // Delete existing items and recreate
            await tx.wishlistItem.deleteMany({
                where: { wishlistId: wishlist.id },
            });

            const wishlistItems = Array.from(productCounts.entries()).map(([productId, quantity]) => ({
                wishlistId: wishlist.id,
                productId,
                quantity,
            }));

            await tx.wishlistItem.createMany({
                data: wishlistItems,
            });

            return tx.wishlist.findUnique({
                where: { id: wishlist.id },
                include: {
                    items: {
                        include: { product: true },
                    },
                    design: {
                        select: { name: true },
                    },
                },
            });
        });
    }

    async getWishlistPreview(designId: string, userId: string) {
        const design = await this.prisma.userDesign.findUnique({
            where: { id: designId },
            include: {
                items: {
                    include: {
                        product: {
                            select: {
                                id: true,
                                name: true,
                                price: true,
                                thumbnailUrl: true,
                                category: true,
                            },
                        },
                    },
                },
            },
        });

        if (!design) {
            throw new NotFoundException('Design not found');
        }

        if (design.userId !== userId) {
            throw new ForbiddenException('You do not have access to this design');
        }

        // Group by product and count
        const productMap = new Map<string, { product: any; quantity: number }>();
        for (const item of design.items) {
            const existing = productMap.get(item.productId);
            if (existing) {
                existing.quantity += 1;
            } else {
                productMap.set(item.productId, {
                    product: item.product,
                    quantity: 1,
                });
            }
        }

        const items = Array.from(productMap.values()).map((entry) => ({
            productId: entry.product.id,
            name: entry.product.name,
            price: entry.product.price,
            thumbnailUrl: entry.product.thumbnailUrl,
            category: entry.product.category,
            quantity: entry.quantity,
            subtotal: (entry.product.price || 0) * entry.quantity,
        }));

        const totalItems = items.reduce((sum, item) => sum + item.quantity, 0);
        const totalCost = items.reduce((sum, item) => sum + item.subtotal, 0);

        return {
            items,
            totalItems,
            totalCost,
        };
    }

    async findAllByUser(userId: string) {
        return this.prisma.wishlist.findMany({
            where: { userId },
            include: {
                _count: {
                    select: { items: true },
                },
                design: {
                    select: { name: true },
                },
            },
            orderBy: { updatedAt: 'desc' },
        });
    }

    async findOne(id: string, userId: string) {
        const wishlist = await this.prisma.wishlist.findUnique({
            where: { id },
            include: {
                items: {
                    include: { product: true },
                },
                design: {
                    select: { name: true },
                },
            },
        });

        if (!wishlist) {
            throw new NotFoundException('Wishlist not found');
        }

        if (wishlist.userId !== userId) {
            throw new ForbiddenException('You do not have access to this wishlist');
        }

        return wishlist;
    }

    async remove(id: string, userId: string) {
        const wishlist = await this.prisma.wishlist.findUnique({ where: { id } });

        if (!wishlist) {
            throw new NotFoundException('Wishlist not found');
        }

        if (wishlist.userId !== userId) {
            throw new ForbiddenException('You do not have access to this wishlist');
        }

        return this.prisma.wishlist.delete({ where: { id } });
    }
}
