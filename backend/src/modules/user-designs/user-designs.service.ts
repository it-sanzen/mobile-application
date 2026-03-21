import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateUserDesignDto } from './dto/create-user-design.dto';
import { DesignItemDto } from './dto/save-design-items.dto';

@Injectable()
export class UserDesignsService {
    constructor(private prisma: PrismaService) { }

    async findAllByUser(userId: string) {
        return this.prisma.userDesign.findMany({
            where: { userId },
            include: {
                showroom: {
                    select: {
                        name: true,
                        roomType: true,
                        style: true,
                        thumbnailUrl: true,
                    },
                },
            },
            orderBy: { updatedAt: 'desc' },
        });
    }

    async findOne(id: string, userId: string) {
        const design = await this.prisma.userDesign.findUnique({
            where: { id },
            include: {
                items: {
                    include: {
                        product: true,
                    },
                },
                showroom: true,
            },
        });

        if (!design) {
            throw new NotFoundException('Design not found');
        }

        if (design.userId !== userId) {
            throw new ForbiddenException('You do not have access to this design');
        }

        return design;
    }

    async create(userId: string, dto: CreateUserDesignDto) {
        return this.prisma.userDesign.create({
            data: {
                userId,
                showroomId: dto.showroomId,
                name: dto.name,
            },
        });
    }

    async update(id: string, userId: string, data: { name?: string; thumbnailUrl?: string; sceneState?: any }) {
        const design = await this.prisma.userDesign.findUnique({ where: { id } });

        if (!design) {
            throw new NotFoundException('Design not found');
        }

        if (design.userId !== userId) {
            throw new ForbiddenException('You do not have access to this design');
        }

        return this.prisma.userDesign.update({
            where: { id },
            data,
        });
    }

    async updateItems(designId: string, userId: string, items: DesignItemDto[]) {
        const design = await this.prisma.userDesign.findUnique({ where: { id: designId } });

        if (!design) {
            throw new NotFoundException('Design not found');
        }

        if (design.userId !== userId) {
            throw new ForbiddenException('You do not have access to this design');
        }

        return this.prisma.$transaction(async (tx) => {
            await tx.designItem.deleteMany({
                where: { designId },
            });

            await tx.designItem.createMany({
                data: items.map((item) => ({
                    designId,
                    productId: item.productId,
                    positionX: item.positionX,
                    positionY: item.positionY,
                    positionZ: item.positionZ,
                    rotationX: item.rotationX,
                    rotationY: item.rotationY,
                    rotationZ: item.rotationZ,
                    scaleX: item.scaleX,
                    scaleY: item.scaleY,
                    scaleZ: item.scaleZ,
                    colorOption: item.colorOption,
                })),
            });

            return this.prisma.userDesign.findUnique({
                where: { id: designId },
                include: {
                    items: {
                        include: { product: true },
                    },
                },
            });
        });
    }

    async uploadScreenshot(designId: string, userId: string, file: Express.Multer.File) {
        const design = await this.prisma.userDesign.findUnique({ where: { id: designId } });

        if (!design) {
            throw new NotFoundException('Design not found');
        }

        if (design.userId !== userId) {
            throw new ForbiddenException('You do not have access to this design');
        }

        const thumbnailUrl = `/uploads/designs/screenshots/${file.filename}`;

        return this.prisma.userDesign.update({
            where: { id: designId },
            data: { thumbnailUrl },
        });
    }

    async remove(id: string, userId: string) {
        const design = await this.prisma.userDesign.findUnique({ where: { id } });

        if (!design) {
            throw new NotFoundException('Design not found');
        }

        if (design.userId !== userId) {
            throw new ForbiddenException('You do not have access to this design');
        }

        return this.prisma.userDesign.delete({ where: { id } });
    }
}
