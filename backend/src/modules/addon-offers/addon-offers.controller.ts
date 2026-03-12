import { Controller, Get, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AddonOffersService } from './addon-offers.service';

@Controller('addon-offers')
export class AddonOffersController {
    constructor(private readonly addonOffersService: AddonOffersService) { }

    @Get()
    @UseGuards(JwtAuthGuard)
    async getAllActiveOffers() {
        return this.addonOffersService.getAllActiveOffers();
    }
}
