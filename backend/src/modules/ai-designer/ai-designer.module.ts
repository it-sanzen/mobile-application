import { Module } from '@nestjs/common';
import { AiDesignerController } from './ai-designer.controller';
import { AiDesignerService } from './ai-designer.service';
import { PrismaModule } from '../../prisma/prisma.module';

@Module({
    imports: [PrismaModule],
    controllers: [AiDesignerController],
    providers: [AiDesignerService],
})
export class AiDesignerModule { }
