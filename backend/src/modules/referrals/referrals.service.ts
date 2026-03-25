import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { SubmitReferralDto } from './dto/submit-referral.dto';
import { UpdateReferralStatusDto } from './dto/update-referral-status.dto';

@Injectable()
export class ReferralsService {
    constructor(
        private prisma: PrismaService,
        private notifications: NotificationsService,
    ) { }

    private generateCode(): string {
        const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
        let code = 'SANZEN-';
        for (let i = 0; i < 6; i++) {
            code += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return code;
    }

    async getOrCreateReferralCode(userId: string) {
        const existing = await this.prisma.referralCode.findFirst({
            where: { userId },
        });

        if (existing) return existing;

        // Generate unique code with retry
        let code: string;
        let attempts = 0;
        while (attempts < 10) {
            code = this.generateCode();
            try {
                return await this.prisma.referralCode.create({
                    data: { userId, code },
                });
            } catch {
                attempts++;
            }
        }

        throw new Error('Could not generate unique referral code');
    }

    async submitReferral(userId: string, dto: SubmitReferralDto) {
        const referralCode = await this.getOrCreateReferralCode(userId);

        return this.prisma.referral.create({
            data: {
                referrerId: userId,
                referralCodeId: referralCode.id,
                referredName: dto.referredName,
                referredPhone: dto.referredPhone,
                referredEmail: dto.referredEmail,
            },
        });
    }

    async getMyDashboard(userId: string) {
        const referralCode = await this.getOrCreateReferralCode(userId);

        const referrals = await this.prisma.referral.findMany({
            where: { referrerId: userId },
            orderBy: { createdAt: 'desc' },
        });

        const totalReferrals = referrals.length;
        const pending = referrals.filter(r => r.status === 'PENDING').length;
        const verified = referrals.filter(r => r.status === 'VERIFIED').length;
        const rewardApplied = referrals.filter(r => r.status === 'REWARD_APPLIED').length;
        const rejected = referrals.filter(r => r.status === 'REJECTED').length;
        const totalRewardsEarned = referrals
            .filter(r => r.status === 'REWARD_APPLIED')
            .reduce((sum, r) => sum + r.rewardAmount, 0);

        return {
            referralCode: referralCode.code,
            stats: {
                totalReferrals,
                pending,
                verified,
                rewardApplied,
                rejected,
                totalRewardsEarned,
            },
            referrals,
        };
    }

    async getById(id: string) {
        const referral = await this.prisma.referral.findUnique({
            where: { id },
            include: {
                referrer: { select: { id: true, name: true, email: true } },
                referralCode: { select: { code: true } },
            },
        });

        if (!referral) {
            throw new NotFoundException('Referral not found');
        }

        return referral;
    }

    async updateStatus(id: string, dto: UpdateReferralStatusDto) {
        const referral = await this.prisma.referral.findUnique({ where: { id } });
        if (!referral) {
            throw new NotFoundException('Referral not found');
        }

        const updated = await this.prisma.referral.update({
            where: { id },
            data: {
                status: dto.status,
                adminNotes: dto.adminNotes,
                appliedToInstallment: dto.appliedToInstallment,
            },
        });

        // Notify referrer about status change
        let message: string;
        switch (dto.status) {
            case 'VERIFIED':
                message = `Your referral for ${referral.referredName} has been verified! Reward will be applied soon.`;
                break;
            case 'REWARD_APPLIED':
                message = `AED ${referral.rewardAmount.toLocaleString()} reward for referring ${referral.referredName} has been applied to installment #${dto.appliedToInstallment ?? 'next'}.`;
                break;
            case 'REJECTED':
                message = `Your referral for ${referral.referredName} was not approved.${dto.adminNotes ? ' Reason: ' + dto.adminNotes : ''}`;
                break;
            default:
                message = `Your referral for ${referral.referredName} status has been updated to ${dto.status}.`;
        }

        await this.notifications.createNotification({
            userId: referral.referrerId,
            title: 'Referral Update',
            message,
            type: 'REFERRAL',
            relatedEntityId: id,
        });

        return updated;
    }

    async getAllForAdmin() {
        return this.prisma.referral.findMany({
            orderBy: { createdAt: 'desc' },
            include: {
                referrer: { select: { id: true, name: true, email: true } },
                referralCode: { select: { code: true } },
            },
        });
    }
}
