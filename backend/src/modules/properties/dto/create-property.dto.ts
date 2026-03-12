import { IsString, IsEnum, IsNumber, IsOptional, IsUrl } from 'class-validator';
import { PropertyType, PropertyStatus } from '@prisma/client';

export class CreatePropertyDto {
    @IsString()
    name: string;

    @IsString()
    location: string;

    @IsEnum(PropertyType)
    propertyType: PropertyType;

    @IsOptional()
    @IsString()
    imageUrl?: string;

    @IsNumber()
    bedrooms: number;

    @IsNumber()
    area: number;

    @IsOptional()
    @IsEnum(PropertyStatus)
    status?: PropertyStatus;

    @IsOptional()
    @IsNumber()
    completionPercentage?: number;

    @IsOptional()
    @IsString()
    currentPhase?: string;

    @IsOptional()
    @IsString()
    estimatedCompletion?: string;
}
