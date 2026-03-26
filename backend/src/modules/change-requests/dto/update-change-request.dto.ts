import { IsString, IsEnum, IsOptional } from 'class-validator';

export enum UpdateChangeRequestCategoryDto {
    STRUCTURAL = 'STRUCTURAL',
    INTERIOR = 'INTERIOR',
    ELECTRICAL = 'ELECTRICAL',
    PLUMBING = 'PLUMBING',
    LAYOUT = 'LAYOUT',
    MATERIAL = 'MATERIAL',
    OTHER = 'OTHER',
}

export class UpdateChangeRequestDto {
    @IsOptional()
    @IsString()
    title?: string;

    @IsOptional()
    @IsString()
    description?: string;

    @IsOptional()
    @IsEnum(UpdateChangeRequestCategoryDto)
    category?: UpdateChangeRequestCategoryDto;
}
