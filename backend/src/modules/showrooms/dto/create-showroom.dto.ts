import { IsString, IsEnum, IsOptional, IsBoolean, IsInt } from 'class-validator';

export class CreateShowroomDto {
  @IsString() name: string;
  @IsString() @IsOptional() description?: string;
  @IsEnum(['LIVING_ROOM', 'BEDROOM', 'KITCHEN', 'BATHROOM', 'OFFICE', 'DINING_ROOM']) roomType: string;
  @IsEnum(['MODERN', 'SCANDINAVIAN', 'MINIMALIST', 'TRADITIONAL', 'INDUSTRIAL', 'BOHEMIAN']) style: string;
  @IsEnum(['EMPTY', 'SEMI_FURNISHED', 'FULLY_FURNISHED']) @IsOptional() furnishingLevel?: string;
  @IsString() modelUrl: string;
  @IsString() @IsOptional() thumbnailUrl?: string;
  @IsOptional() floorDimensions?: any;
  @IsOptional() defaultItems?: any;
  @IsInt() @IsOptional() sortOrder?: number;
}
