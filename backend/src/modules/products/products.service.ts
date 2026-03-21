import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateProductDto } from './dto/create-product.dto';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  async findAll(filters: {
    category?: string;
    tag?: string;
    minPrice?: number;
    maxPrice?: number;
    featured?: boolean;
    limit?: number;
    offset?: number;
  }) {
    const where: any = { isActive: true };

    if (filters.category) {
      where.category = filters.category;
    }
    if (filters.tag) {
      where.tags = { has: filters.tag };
    }
    if (filters.minPrice !== undefined || filters.maxPrice !== undefined) {
      where.price = {};
      if (filters.minPrice !== undefined) {
        where.price.gte = filters.minPrice;
      }
      if (filters.maxPrice !== undefined) {
        where.price.lte = filters.maxPrice;
      }
    }
    if (filters.featured !== undefined) {
      where.isFeatured = filters.featured;
    }

    return this.prisma.furnitureProduct.findMany({
      where,
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
      take: filters.limit || undefined,
      skip: filters.offset || undefined,
    });
  }

  async search(query: string) {
    return this.prisma.furnitureProduct.findMany({
      where: {
        isActive: true,
        OR: [
          { name: { contains: query, mode: 'insensitive' } },
          { tags: { has: query } },
        ],
      },
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
    });
  }

  async findCategories() {
    const groups = await this.prisma.furnitureProduct.groupBy({
      by: ['category'],
      where: { isActive: true },
      _count: { id: true },
    });

    return groups.map((group) => ({
      category: group.category,
      count: group._count.id,
    }));
  }

  async findSimilar(id: string) {
    const product = await this.prisma.furnitureProduct.findUnique({ where: { id } });
    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }

    const where: any = {
      isActive: true,
      category: product.category,
      id: { not: id },
    };

    // If the product has dimensions, find items within +-30%
    if (product.dimensions && typeof product.dimensions === 'object') {
      const dims = product.dimensions as any;
      if (dims.width) {
        where.dimensions = {
          path: ['width'],
          gte: dims.width * 0.7,
          lte: dims.width * 1.3,
        };
      }
    }

    return this.prisma.furnitureProduct.findMany({
      where,
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
      take: 10,
    });
  }

  async findOne(id: string) {
    const product = await this.prisma.furnitureProduct.findUnique({ where: { id } });
    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }
    return product;
  }

  async create(dto: CreateProductDto) {
    return this.prisma.furnitureProduct.create({ data: dto as any });
  }

  async bulkCreate(dtos: CreateProductDto[]) {
    return this.prisma.furnitureProduct.createMany({ data: dtos as any[] });
  }

  async update(id: string, dto: Partial<CreateProductDto>) {
    await this.findOne(id);
    return this.prisma.furnitureProduct.update({
      where: { id },
      data: dto as any,
    });
  }

  async softDelete(id: string) {
    await this.findOne(id);
    return this.prisma.furnitureProduct.update({
      where: { id },
      data: { isActive: false },
    });
  }
}
