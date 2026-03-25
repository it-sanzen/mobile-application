import { IsString, IsEnum, IsOptional, IsNumber } from 'class-validator';

export enum ChangeRequestStatusDto {
    SUBMITTED = 'SUBMITTED',
    UNDER_REVIEW = 'UNDER_REVIEW',
    APPROVED = 'APPROVED',
    REJECTED = 'REJECTED',
}

export class UpdateChangeRequestStatusDto {
    @IsEnum(ChangeRequestStatusDto)
    status: ChangeRequestStatusDto;

    @IsOptional()
    @IsString()
    adminNotes?: string;

    @IsOptional()
    @IsNumber()
    costImpact?: number;

    @IsOptional()
    @IsString()
    timelineImpact?: string;
}
