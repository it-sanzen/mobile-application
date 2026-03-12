import { Module } from '@nestjs/common';
import { AddonOffersController } from './addon-offers.controller';
import { AddonOffersService } from './addon-offers.service';
import { PrismaModule } from '../../prisma/prisma.module';

@Module({
    imports: [PrismaModule],
    controllers: [AddonOffersController],
    providers: [AddonOffersService],
    exports: [AddonOffersService],
})
export class AddonOffersModule { }
