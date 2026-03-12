import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class CompanyNewsService {
    constructor(private prisma: PrismaService) { }

    async findAll() {
        return this.prisma.companyNews.findMany({
            where: {
                isPublished: true,
            },
            orderBy: {
                publishedAt: 'desc',
            },
            select: {
                id: true,
                category: true,
                title: true,
                description: true,
                time: true,
                publishedAt: true,
                isPublished: true,
                isFeatured: true,
            },
        });
    }

    async create(data: any) {
        return this.prisma.companyNews.create({
            data: {
                ...data,
                publishedAt: data.isPublished ? new Date() : null,
            },
        });
    }

    async update(id: string, data: any) {
        return this.prisma.companyNews.update({
            where: { id },
            data: {
                ...data,
                publishedAt: data.isPublished ? new Date() : null,
            },
        });
    }

    async remove(id: string) {
        return this.prisma.companyNews.delete({
            where: { id },
        });
    }
}
