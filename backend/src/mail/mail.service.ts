import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';

@Injectable()
export class MailService {
    private transporter: nodemailer.Transporter;
    private readonly logger = new Logger(MailService.name);

    constructor(private configService: ConfigService) {
        this.transporter = nodemailer.createTransport({
            host: this.configService.get<string>('SMTP_HOST'),
            port: this.configService.get<number>('SMTP_PORT'),
            secure: this.configService.get<number>('SMTP_PORT') === 465, // true for 465, false for other ports
            auth: {
                user: this.configService.get<string>('SMTP_USER'),
                pass: this.configService.get<string>('SMTP_PASS'),
            },
        });
    }

    async sendPasswordResetEmail(to: string, otp: string) {
        const from = this.configService.get<string>('SMTP_FROM') || '"Sanzen App" <noreply@sanzen.ae>';

        try {
            await this.transporter.sendMail({
                from,
                to,
                subject: 'Reset Your Sanzen Password',
                html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; color: #333;">
            <h2 style="color: #1D3724;">Password Reset Request</h2>
            <p>You recently requested to reset your password for your Sanzen App account.</p>
            <p>Your one-time password (OTP) reset code is:</p>
            <div style="background-color: #f4f4f4; padding: 15px; text-align: center; border-radius: 5px; margin: 20px 0;">
              <h1 style="letter-spacing: 5px; margin: 0; color: #1D3724;">${otp}</h1>
            </div>
            <p><strong>This code will expire in 15 minutes.</strong></p>
            <p>If you did not request a password reset, please ignore this email or contact support if you have concerns.</p>
            <br>
            <p>Best regards,<br>The Sanzen Team</p>
          </div>
        `,
            });
            this.logger.log(`Password reset email sent to ${to}`);
        } catch (error) {
            this.logger.error(`Failed to send password reset email to ${to}`, error);
            throw error; // Let the caller handle it or fail gracefully
        }
    }
}
