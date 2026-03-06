import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class DocumentsService {
    constructor(private prisma: PrismaService) { }

    async create(data: { title: string; type: string; fileUrl: string; userId: string }) {
        return this.prisma.document.create({
            data,
        });
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
        return this.prisma.document.findMany({
            where: { userId },
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
