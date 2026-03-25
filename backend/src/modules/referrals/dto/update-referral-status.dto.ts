import { IsString, IsEnum, IsOptional, IsNumber } from 'class-validator';

export enum ReferralStatusDto {
    PENDING = 'PENDING',
    VERIFIED = 'VERIFIED',
    REWARD_APPLIED = 'REWARD_APPLIED',
    REJECTED = 'REJECTED',
}

export class UpdateReferralStatusDto {
    @IsEnum(ReferralStatusDto)
    status: ReferralStatusDto;

    @IsOptional()
    @IsString()
    adminNotes?: string;

    @IsOptional()
    @IsNumber()
    appliedToInstallment?: number;
}
