import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
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

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    PrismaModule,
    AuthModule,
    UsersModule,
    AkaratiModule,
    AutomationModule,
    CompanyModule,
    NotificationsModule,
    MailModule,
    DocumentsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
