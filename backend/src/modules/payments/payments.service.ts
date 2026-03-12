import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class PaymentsService {
    constructor(private prisma: PrismaService) { }

    async getUserPayments(userId: string, status?: string) {
        return this.prisma.payment.findMany({
            where: {
                userId,
                ...(status && { status: status as any }),
            },
            include: {
                property: {
                    select: {
                        id: true,
                        name: true,
                        location: true,
                        propertyType: true,
                    },
                },
            },
            orderBy: {
                dueDate: 'desc',
            },
        });
    }

    async getPaymentById(paymentId: string, userId: string) {
        return this.prisma.payment.findFirst({
            where: {
                id: paymentId,
                userId,
            },
            include: {
                property: true,
            },
        });
    }

    async getPaymentSummary(userId: string) {
        const payments = await this.prisma.payment.findMany({
            where: { userId },
        });

        const total = payments.reduce((sum, p) => sum + p.amount, 0);
        const paid = payments
            .filter(p => p.status === 'PAID')
            .reduce((sum, p) => sum + p.amount, 0);
        const pending = payments
            .filter(p => p.status === 'PENDING')
            .reduce((sum, p) => sum + p.amount, 0);
        const overdue = payments
            .filter(p => p.status === 'OVERDUE')
            .reduce((sum, p) => sum + p.amount, 0);

        return {
            total,
            paid,
            pending,
            overdue,
            paymentCount: payments.length,
            paidCount: payments.filter(p => p.status === 'PAID').length,
            pendingCount: payments.filter(p => p.status === 'PENDING').length,
            overdueCount: payments.filter(p => p.status === 'OVERDUE').length,
        };
    }
}
