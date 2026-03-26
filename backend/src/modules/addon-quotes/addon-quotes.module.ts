import { Module } from '@nestjs/common';
import { AddonQuotesController } from './addon-quotes.controller';
import { AddonQuotesService } from './addon-quotes.service';
import { PrismaModule } from '../../prisma/prisma.module';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
    imports: [PrismaModule, NotificationsModule],
    controllers: [AddonQuotesController],
    providers: [AddonQuotesService],
    exports: [AddonQuotesService],
})
export class AddonQuotesModule { }
