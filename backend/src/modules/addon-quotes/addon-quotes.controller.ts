import { Controller, Get, Post, Patch, Param, Body, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminGuard } from '../../auth/guards/admin.guard';
import { AddonQuotesService } from './addon-quotes.service';
import { CreateAddonQuoteDto } from './dto/create-addon-quote.dto';
import { UpdateAddonQuoteStatusDto } from './dto/update-addon-quote-status.dto';

@Controller('addon-quotes')
export class AddonQuotesController {
    constructor(private readonly service: AddonQuotesService) { }

    @Post()
    @UseGuards(JwtAuthGuard)
    create(@Req() req: any, @Body() dto: CreateAddonQuoteDto) {
        return this.service.create(req.user.userId, dto);
    }

    @Get()
    @UseGuards(JwtAuthGuard)
    getMyQuotes(@Req() req: any) {
        return this.service.getMyQuotes(req.user.userId);
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
    updateStatus(@Param('id') id: string, @Body() dto: UpdateAddonQuoteStatusDto) {
        return this.service.updateStatus(id, dto);
    }
}
