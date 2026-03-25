import { Controller, Get, Post, Patch, Param, Body, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminGuard } from '../../auth/guards/admin.guard';
import { ChangeRequestsService } from './change-requests.service';
import { CreateChangeRequestDto } from './dto/create-change-request.dto';
import { UpdateChangeRequestStatusDto } from './dto/update-change-request-status.dto';

@Controller('change-requests')
export class ChangeRequestsController {
    constructor(private readonly service: ChangeRequestsService) { }

    @Post()
    @UseGuards(JwtAuthGuard)
    create(@Req() req: any, @Body() dto: CreateChangeRequestDto) {
        return this.service.create(req.user.userId, dto);
    }

    @Get()
    @UseGuards(JwtAuthGuard)
    getMyRequests(@Req() req: any) {
        return this.service.getMyRequests(req.user.userId);
    }

    @Get('admin/all')
    @UseGuards(JwtAuthGuard, AdminGuard)
    getAllForAdmin() {
        return this.service.getAllForAdmin();
    }

    @Get(':id')
    @UseGuards(JwtAuthGuard)
    getById(@Param('id') id: string) {
        return this.service.getById(id);
    }

    @Patch(':id/status')
    @UseGuards(JwtAuthGuard, AdminGuard)
    updateStatus(@Param('id') id: string, @Body() dto: UpdateChangeRequestStatusDto) {
        return this.service.updateStatus(id, dto);
    }
}
