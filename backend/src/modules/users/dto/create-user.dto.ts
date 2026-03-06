import { IsEmail, IsString, MinLength, IsBoolean, IsOptional } from 'class-validator';

export class CreateUserDto {
    @IsEmail({}, { message: 'Invalid email address format' })
    email: string;

    @IsString()
    @MinLength(6, { message: 'Password must be at least 6 characters long' })
    password: string;

    @IsString()
    name: string;

    @IsString()
    @IsOptional()
    phone?: string;

    @IsString()
    @IsOptional()
    address?: string;

    @IsString()
    @IsOptional()
    unit?: string;
}
