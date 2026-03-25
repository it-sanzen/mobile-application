import { IsString, IsEnum } from 'class-validator';

export enum ChangeRequestCategoryDto {
    STRUCTURAL = 'STRUCTURAL',
    INTERIOR = 'INTERIOR',
    ELECTRICAL = 'ELECTRICAL',
    PLUMBING = 'PLUMBING',
    LAYOUT = 'LAYOUT',
    MATERIAL = 'MATERIAL',
    OTHER = 'OTHER',
}

export class CreateChangeRequestDto {
    @IsString()
    propertyId: string;

    @IsString()
    title: string;

    @IsString()
    description: string;

    @IsEnum(ChangeRequestCategoryDto)
    category: ChangeRequestCategoryDto;
}
