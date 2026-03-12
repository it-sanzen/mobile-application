import { Module } from '@nestjs/common';
import { CompanyNewsController } from './company-news.controller';
import { CompanyNewsService } from './company-news.service';
import { PrismaModule } from '../../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [CompanyNewsController],
  providers: [CompanyNewsService],
})
export class CompanyNewsModule { }
