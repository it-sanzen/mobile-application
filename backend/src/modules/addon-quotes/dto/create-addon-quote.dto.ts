import { IsString, IsArray, ArrayMinSize } from 'class-validator';

export class CreateAddonQuoteDto {
    @IsString()
    propertyId: string;

    @IsArray()
    @ArrayMinSize(1)
    addonOfferIds: string[];
}
