import { Module } from '@nestjs/common';
import { ShowroomsController } from './showrooms.controller';
import { ShowroomsService } from './showrooms.service';
import { PrismaModule } from '../../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [ShowroomsController],
  providers: [ShowroomsService],
  exports: [ShowroomsService],
})
export class ShowroomsModule {}
