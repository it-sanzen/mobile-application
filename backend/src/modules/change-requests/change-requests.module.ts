import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { ChangeRequestsController } from './change-requests.controller';
import { ChangeRequestsService } from './change-requests.service';

@Module({
    imports: [PrismaModule, NotificationsModule],
    controllers: [ChangeRequestsController],
    providers: [ChangeRequestsService],
    exports: [ChangeRequestsService],
})
export class ChangeRequestsModule { }
