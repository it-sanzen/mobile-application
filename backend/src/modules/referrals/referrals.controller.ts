import { Controller, Get, Post, Patch, Param, Body, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminGuard } from '../../auth/guards/admin.guard';
import { ReferralsService } from './referrals.service';
import { SubmitReferralDto } from './dto/submit-referral.dto';
import { UpdateReferralStatusDto } from './dto/update-referral-status.dto';

@Controller('referrals')
export class ReferralsController {
    constructor(private readonly service: ReferralsService) { }

    @Get('my-code')
    @UseGuards(JwtAuthGuard)
    getMyCode(@Req() req: any) {
        return this.service.getOrCreateReferralCode(req.user.userId);
    }

    @Post()
    @UseGuards(JwtAuthGuard)
    submit(@Req() req: any, @Body() dto: SubmitReferralDto) {
        return this.service.submitReferral(req.user.userId, dto);
    }

    @Get('dashboard')
    @UseGuards(JwtAuthGuard)
    getDashboard(@Req() req: any) {
        return this.service.getMyDashboard(req.user.userId);
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
    updateStatus(@Param('id') id: string, @Body() dto: UpdateReferralStatusDto) {
        return this.service.updateStatus(id, dto);
    }
}
