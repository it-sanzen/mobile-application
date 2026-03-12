import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class PaymentsCronService {
    private readonly logger = new Logger(PaymentsCronService.name);

    constructor(
        private prisma: PrismaService,
        private notificationsService: NotificationsService
    ) { }

    // Run every day at midnight. 
    // (Change to CronExpression.EVERY_MINUTE for testing purposes if you want)
    @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
    async handleUpcomingPayments() {
        this.logger.log('Starting daily check for upcoming payments (30 days out)...');

        // 1. Calculate the target date (exactly 30 days from now)
        const targetDate = new Date();
        targetDate.setDate(targetDate.getDate() + 30);

        // Create start and end of that specific day
        const startOfDay = new Date(targetDate);
        startOfDay.setHours(0, 0, 0, 0);

        const endOfDay = new Date(targetDate);
        endOfDay.setHours(23, 59, 59, 999);

        try {
            // 2. Find all pending payments due on that exact day
            const upcomingPayments = await this.prisma.payment.findMany({
                where: {
                    status: 'PENDING',
                    dueDate: {
                        gte: startOfDay,
                        lte: endOfDay,
                    },
                },
                include: {
                    property: true,
                }
            });

            this.logger.log(`Found ${upcomingPayments.length} upcoming payments due on ${targetDate.toDateString()}`);

            // 3. For each payment, create a Global Notification
            for (const payment of upcomingPayments) {

                // Ensure we don't spam them by checking if an update for this specific payment already exists
                const existingNotification = await this.prisma.notification.findFirst({
                    where: {
                        userId: payment.userId,
                        type: 'PAYMENT',
                        relatedEntityId: payment.id,
                        createdAt: {
                            gte: new Date(Date.now() - 24 * 60 * 60 * 1000) // Within the last 24 hours
                        }
                    }
                });

                if (existingNotification) {
                    this.logger.debug(`Notification already sent recently for payment ${payment.id}. Skipping.`);
                    continue;
                }

                const propertyName = payment.property ? payment.property.name : 'your property';

                // ALSO TRIGGER PERSISTENT INBOX NOTIFICATION
                await this.notificationsService.createNotification({
                    userId: payment.userId,
                    title: 'Upcoming Payment Reminder',
                    message: `Your next installment of AED ${payment.amount} for ${propertyName} is due.`,
                    type: 'PAYMENT',
                    relatedEntityId: payment.id,
                });

                this.logger.log(`Created payment reminder notification for user ${payment.userId}`);
            }

            this.logger.log('Daily payment check completed successfully.');
        } catch (error) {
            this.logger.error('Error running payment cron job:', error);
        }
    }
}
