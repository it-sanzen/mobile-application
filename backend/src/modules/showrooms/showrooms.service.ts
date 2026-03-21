import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateShowroomDto } from './dto/create-showroom.dto';

@Injectable()
export class ShowroomsService {
  constructor(private prisma: PrismaService) {}

  async findAll(filters: { roomType?: string; style?: string; furnishingLevel?: string }) {
    const where: any = { isActive: true };

    if (filters.roomType) {
      where.roomType = filters.roomType;
    }
    if (filters.style) {
      where.style = filters.style;
    }
    if (filters.furnishingLevel) {
      where.furnishingLevel = filters.furnishingLevel;
    }

    return this.prisma.showroomTemplate.findMany({
      where,
      orderBy: { sortOrder: 'asc' },
    });
  }

  async findCategories() {
    const groups = await this.prisma.showroomTemplate.groupBy({
      by: ['roomType'],
      where: { isActive: true },
      _count: { id: true },
    });

    const categories = await Promise.all(
      groups.map(async (group) => {
        const firstShowroom = await this.prisma.showroomTemplate.findFirst({
          where: { roomType: group.roomType, isActive: true },
          select: { thumbnailUrl: true },
          orderBy: { sortOrder: 'asc' },
        });

        return {
          roomType: group.roomType,
          count: group._count.id,
          thumbnailUrl: firstShowroom?.thumbnailUrl || null,
        };
      }),
    );

    return categories;
  }

  async findOne(id: string) {
    const showroom = await this.prisma.showroomTemplate.findUnique({ where: { id } });
    if (!showroom) {
      throw new NotFoundException(`Showroom with ID ${id} not found`);
    }
    return showroom;
  }

  async create(dto: CreateShowroomDto) {
    return this.prisma.showroomTemplate.create({ data: dto as any });
  }

  async update(id: string, dto: Partial<CreateShowroomDto>) {
    await this.findOne(id);
    return this.prisma.showroomTemplate.update({
      where: { id },
      data: dto as any,
    });
  }

  async softDelete(id: string) {
    await this.findOne(id);
    return this.prisma.showroomTemplate.update({
      where: { id },
      data: { isActive: false },
    });
  }
}
