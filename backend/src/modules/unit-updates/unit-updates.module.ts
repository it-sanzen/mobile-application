import { Module } from '@nestjs/common';
import { UnitUpdatesController } from './unit-updates.controller';
import { UnitUpdatesService } from './unit-updates.service';
import { PrismaModule } from '../../prisma/prisma.module';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [PrismaModule, NotificationsModule],
  controllers: [UnitUpdatesController],
  providers: [UnitUpdatesService],
})
export class UnitUpdatesModule { }
