import { IsNotEmpty, IsString } from 'class-validator';

export class CreateUserDesignDto {
    @IsString()
    @IsNotEmpty()
    showroomId: string;

    @IsString()
    @IsNotEmpty()
    name: string;
}
