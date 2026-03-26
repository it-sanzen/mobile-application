import { IsString, IsEnum, IsOptional } from 'class-validator';

export enum AddonQuoteStatusDto {
    PENDING = 'PENDING',
    REVIEWED = 'REVIEWED',
    APPROVED = 'APPROVED',
    REJECTED = 'REJECTED',
}

export class UpdateAddonQuoteStatusDto {
    @IsEnum(AddonQuoteStatusDto)
    status: AddonQuoteStatusDto;

    @IsOptional()
    @IsString()
    adminNotes?: string;
}
