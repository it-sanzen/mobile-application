import { Controller, Get, Param, Query, Req, UseGuards } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@Controller('payments')
export class PaymentsController {
    constructor(private readonly paymentsService: PaymentsService) { }

    @Get('my')
    @UseGuards(JwtAuthGuard)
    async getMyPayments(@Req() req: any, @Query('status') status?: string) {
        return this.paymentsService.getUserPayments(req.user.userId, status);
    }

    @Get('summary')
    @UseGuards(JwtAuthGuard)
    async getPaymentSummary(@Req() req: any) {
        return this.paymentsService.getPaymentSummary(req.user.userId);
    }

    @Get(':id')
    @UseGuards(JwtAuthGuard)
    async getPaymentById(@Param('id') id: string, @Req() req: any) {
        return this.paymentsService.getPaymentById(id, req.user.userId);
    }
}
