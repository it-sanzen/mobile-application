import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { UsersModule } from './modules/users/users.module';
import { AkaratiModule } from './modules/integrations/akarati/akarati.module';
import { AutomationModule } from './modules/integrations/automation/automation.module';
import { CompanyModule } from './modules/integrations/company/company.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { AuthModule } from './auth/auth.module';
import { MailModule } from './mail/mail.module';
import { DocumentsModule } from './modules/documents/documents.module';
import { UnitUpdatesModule } from './modules/unit-updates/unit-updates.module';
import { CompanyNewsModule } from './modules/company-news/company-news.module';
import { PropertiesModule } from './modules/properties/properties.module';
import { TimelineModule } from './modules/timeline/timeline.module';
import { AddonOffersModule } from './modules/addon-offers/addon-offers.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { AiDesignerModule } from './modules/ai-designer/ai-designer.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    ScheduleModule.forRoot(),
    PrismaModule,
    AuthModule,
    UsersModule,
    AkaratiModule,
    AutomationModule,
    CompanyModule,
    NotificationsModule,
    MailModule,
    DocumentsModule,
    UnitUpdatesModule,
    CompanyNewsModule,
    PropertiesModule,
    TimelineModule,
    AddonOffersModule,
    PaymentsModule,
    AiDesignerModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }

