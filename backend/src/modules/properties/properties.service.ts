import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class PropertiesService {
    constructor(private prisma: PrismaService) { }

    async getUserPrimaryProperty(userId: string) {
        const userProperty = await this.prisma.userProperty.findFirst({
            where: {
                userId,
                isPrimary: true,
            },
            include: {
                property: true,
            },
        });

        if (!userProperty) {
            return null;
        }

        return {
            ...userProperty.property,
            unitCode: userProperty.unitCode,
        };
    }

    async getUserProperties(userId: string, propertyType?: string) {
        const userProperties = await this.prisma.userProperty.findMany({
            where: {
                userId,
                ...(propertyType && {
                    property: {
                        propertyType: propertyType as any,
                    },
                }),
            },
            include: {
                property: true,
            },
            orderBy: {
                isPrimary: 'desc',
            },
        });

        return userProperties.map(up => ({
            ...up.property,
            unitCode: up.unitCode,
            isPrimary: up.isPrimary,
        }));
    }

    async getAllProperties() {
        return this.prisma.property.findMany({
            orderBy: { name: 'asc' }
        });
    }

    async createProperty(data: any) {
        return this.prisma.property.create({
            data,
        });
    }

    async updateProperty(id: string, data: any) {
        return this.prisma.property.update({
            where: { id },
            data,
        });
    }

    async deleteProperty(id: string) {
        return this.prisma.property.delete({
            where: { id },
        });
    }
}
