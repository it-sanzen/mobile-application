import { Injectable, UnauthorizedException, ConflictException, NotFoundException, BadRequestException, ForbiddenException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcryptjs';
import { SignupDto, SigninDto, ForgotPasswordDto, ResetPasswordDto, UpdateProfileDto, ChangePasswordDto } from './dto/auth.dto';
import { MailService } from '../mail/mail.service';
import * as crypto from 'crypto';

@Injectable()
export class AuthService {
    private readonly logger = new Logger(AuthService.name);

    constructor(
        private prisma: PrismaService,
        private jwtService: JwtService,
        private mailService: MailService,
        private configService: ConfigService,
    ) { }

    async signup(dto: SignupDto) {
        // Check if user exists
        const existingUser = await this.prisma.user.findFirst({
            where: {
                OR: [
                    { email: dto.email },
                    { phone: dto.phone || undefined }
                ].filter(condition => condition.phone !== undefined || condition.email)
            }
        });

        if (existingUser) {
            if (existingUser.email === dto.email) {
                throw new ConflictException('Email is already registered');
            }
            throw new ConflictException('Phone number is already registered');
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(dto.password, 10);

        // Create user
        const user = await this.prisma.user.create({
            data: {
                email: dto.email,
                password: hashedPassword,
                name: dto.name,
                phone: dto.phone,
                address: dto.address,
                unit: dto.unit,
            },
        });

        const token = this.generateToken(user.id, user.email);

        return {
            message: 'User created successfully',
            user,
            token,
        };
    }

    async signin(dto: SigninDto) {
        const masterAdminEmail = this.configService.get<string>('ADMIN_EMAIL');
        const masterAdminPassword = this.configService.get<string>('ADMIN_PASSWORD');

        const inputEmail = dto.email.toLowerCase().trim();
        const inputPassword = dto.password.trim();

        this.logger.log(`Signin attempt for: ${inputEmail}`);

        if (masterAdminEmail && masterAdminPassword &&
            inputEmail === masterAdminEmail.toLowerCase().trim() &&
            inputPassword === masterAdminPassword.trim()) {

            this.logger.log('Master Admin logged in');
            const token = this.generateToken('admin-system-id', masterAdminEmail);
            return {
                message: 'Logged in successfully as Master Admin',
                user: {
                    id: 'admin-system-id',
                    email: masterAdminEmail,
                    name: 'Super Admin',
                    isAdmin: true,
                },
                token,
            };
        }

        const user = await this.prisma.user.findUnique({
            where: { email: inputEmail },
        });

        if (!user) {
            this.logger.warn(`User not found: ${inputEmail}`);
            throw new UnauthorizedException('Invalid credentials');
        }

        const isPasswordValid = await bcrypt.compare(inputPassword, user.password);

        if (!isPasswordValid) {
            this.logger.warn(`Invalid password for user: ${inputEmail}`);
            throw new UnauthorizedException('Invalid credentials');
        }


        const token = this.generateToken(user.id, user.email);

        // Optionally save session to DB here if needed

        return {
            message: 'Logged in successfully',
            user: {
                id: user.id,
                email: user.email,
                name: user.name,
                phone: user.phone,
                address: user.address,
                unit: user.unit,
                createdAt: user.createdAt,
            },
            token,
        };
    }

    async logout(userId: string) {
        // If using DB sessions or refresh tokens, invalidate them here
        // For simple JWT, client just throws away the token
        return { message: 'Logged out successfully' };
    }

    async getProfile(userId: string) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId }
        });

        if (!user) throw new NotFoundException('User not found');
        return user;
    }

    async updateProfile(userId: string, dto: UpdateProfileDto) {
        const user = await this.prisma.user.update({
            where: { id: userId },
            data: {
                ...dto
            }
        });

        return {
            message: 'Profile updated successfully',
            user
        };
    }

    async changePassword(userId: string, dto: ChangePasswordDto) {
        const user = await this.prisma.user.findUnique({ where: { id: userId } });
        if (!user) throw new NotFoundException('User not found');

        const isPasswordValid = await bcrypt.compare(dto.currentPassword, user.password);
        if (!isPasswordValid) throw new UnauthorizedException('Invalid current password');

        const hashedNewPassword = await bcrypt.hash(dto.newPassword, 10);

        await this.prisma.user.update({
            where: { id: userId },
            data: { password: hashedNewPassword }
        });

        return { message: 'Password changed successfully' };
    }

    async forgotPassword(dto: ForgotPasswordDto) {
        const user = await this.prisma.user.findUnique({ where: { email: dto.email } });
        if (!user) {
            // Return success even if not found to prevent email enumeration
            return { message: 'If that email is registered, a password reset link has been sent.' };
        }

        // 1. Generate 6-digit OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();

        // 2. Hash it securely
        const hashedOtp = crypto.createHash('sha256').update(otp).digest('hex');

        // 3. Set expiry to 15 mins from now
        const expiryTime = new Date();
        expiryTime.setMinutes(expiryTime.getMinutes() + 15);

        await this.prisma.user.update({
            where: { id: user.id },
            data: {
                resetToken: hashedOtp,
                resetTokenExpiry: expiryTime,
            }
        });

        // 4. Send the email via MailService
        await this.mailService.sendPasswordResetEmail(user.email, otp);

        return { message: 'If that email is registered, a password reset link has been sent.' };
    }

    async verifyOtp(email: string, otp: string) {
        const user = await this.prisma.user.findUnique({ where: { email } });
        if (!user || !user.resetToken || !user.resetTokenExpiry) {
            throw new BadRequestException('Invalid or expired OTP');
        }

        if (new Date() > user.resetTokenExpiry) {
            throw new BadRequestException('OTP has expired');
        }

        const hashedOtp = crypto.createHash('sha256').update(otp).digest('hex');
        if (hashedOtp !== user.resetToken) {
            throw new BadRequestException('Invalid OTP');
        }

        return { message: 'OTP verified successfully', valid: true };
    }

    async resetPassword(dto: ResetPasswordDto) {
        // Find user by assuming DTO has `email` or passing it alongside token if not already
        // Note: The original DTO `ResetPasswordDto` might only contain `token` and `password`.
        // We will decode the token to find the email, or modify the DTO depending on the design.
        // For OTP, `token` typically acts as the OTP value itself during final submission.

        // **Wait, the standard Flow:**
        // We need an identifier. Let's find any user matching this un-expired hashed token.
        const hashedOtp = crypto.createHash('sha256').update(dto.token).digest('hex');

        const user = await this.prisma.user.findFirst({
            where: {
                email: dto.email,
                resetToken: hashedOtp,
                resetTokenExpiry: {
                    gt: new Date() // Must not be expired
                }
            }
        });

        if (!user) {
            throw new BadRequestException('Invalid or expired reset token');
        }

        const hashedNewPassword = await bcrypt.hash(dto.password, 10);

        await this.prisma.user.update({
            where: { id: user.id },
            data: {
                password: hashedNewPassword,
                resetToken: null,
                resetTokenExpiry: null, // Clear the token!
            }
        });

        return { message: 'Password has been reset successfully' };
    }

    // Helper method
    private generateToken(userId: string, email: string) {
        const payload = { sub: userId, email };
        return {
            accessToken: this.jwtService.sign(payload, {
                secret: process.env.JWT_SECRET || 'secret',
                expiresIn: (process.env.JWT_EXPIRATION || '15m') as any
            }),
            // Mock refresh token for now
            refreshToken: this.jwtService.sign(payload, {
                secret: process.env.JWT_REFRESH_SECRET || 'refresh-secret',
                expiresIn: (process.env.JWT_REFRESH_EXPIRATION || '7d') as any
            })
        };
    }

}
