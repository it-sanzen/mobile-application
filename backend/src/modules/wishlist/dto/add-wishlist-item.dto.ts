import { IsNotEmpty, IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class AddWishlistItemDto {
    @IsString()
    @IsNotEmpty()
    productId: string;

    @IsNumber()
    @IsOptional()
    @Min(1)
    quantity?: number = 1;

    @IsString()
    @IsOptional()
    notes?: string;
}
