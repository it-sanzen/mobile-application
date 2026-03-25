import { IsString, IsOptional, IsEmail } from 'class-validator';

export class SubmitReferralDto {
    @IsString()
    referredName: string;

    @IsString()
    referredPhone: string;

    @IsOptional()
    @IsEmail()
    referredEmail?: string;
}
