import { IsString, IsEnum, IsOptional, IsNumber, IsBoolean, IsArray } from 'class-validator';

export class CreateProductDto {
  @IsString() name: string;
  @IsString() @IsOptional() description?: string;
  @IsEnum(['SOFA', 'BED', 'TABLE', 'CHAIR', 'STORAGE', 'LIGHTING', 'RUG', 'DECOR', 'PLANT', 'KITCHEN_FIXTURE', 'BATHROOM_FIXTURE']) category: string;
  @IsString() @IsOptional() subcategory?: string;
  @IsString() @IsOptional() brand?: string;
  @IsNumber() @IsOptional() price?: number;
  @IsString() @IsOptional() currency?: string;
  @IsString() thumbnailUrl: string;
  @IsString() modelUrl: string;
  @IsOptional() dimensions?: any;
  @IsOptional() colorOptions?: any;
  @IsArray() @IsOptional() tags?: string[];
  @IsBoolean() @IsOptional() isFeatured?: boolean;
}
