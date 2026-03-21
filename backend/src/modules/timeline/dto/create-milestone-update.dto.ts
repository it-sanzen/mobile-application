import { IsString, IsNotEmpty, IsOptional, IsEnum } from 'class-validator';

export class CreateMilestoneUpdateDto {
    @IsString()
    @IsNotEmpty()
    notes: string;
}

export class UploadBeforeAfterDto {
    @IsEnum(['BEFORE', 'AFTER'])
    photoType: 'BEFORE' | 'AFTER';

    @IsString()
    @IsOptional()
    caption?: string;
}
