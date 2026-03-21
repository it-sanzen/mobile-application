import { IsArray, IsNotEmpty, IsNumber, IsOptional, IsString, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export class DesignItemDto {
    @IsString()
    @IsNotEmpty()
    productId: string;

    @IsNumber()
    positionX: number;

    @IsNumber()
    positionY: number;

    @IsNumber()
    positionZ: number;

    @IsNumber()
    rotationX: number;

    @IsNumber()
    rotationY: number;

    @IsNumber()
    rotationZ: number;

    @IsNumber()
    scaleX: number;

    @IsNumber()
    scaleY: number;

    @IsNumber()
    scaleZ: number;

    @IsString()
    @IsOptional()
    colorOption?: string;
}

export class SaveDesignItemsDto {
    @IsArray()
    @ValidateNested({ each: true })
    @Type(() => DesignItemDto)
    items: DesignItemDto[];
}
