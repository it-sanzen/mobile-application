import { Controller, Get, Post, Delete, Param, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { WishlistService } from './wishlist.service';

@Controller('wishlist')
export class WishlistController {
    constructor(private readonly wishlistService: WishlistService) { }

    @Get('from-design/:designId')
    @UseGuards(JwtAuthGuard)
    async getWishlistPreview(@Param('designId') designId: string, @Req() req: any) {
        return this.wishlistService.getWishlistPreview(designId, req.user.userId);
    }

    @Post('from-design/:designId')
    @UseGuards(JwtAuthGuard)
    async generateFromDesign(@Param('designId') designId: string, @Req() req: any) {
        return this.wishlistService.generateFromDesign(designId, req.user.userId);
    }

    @Get()
    @UseGuards(JwtAuthGuard)
    async findAll(@Req() req: any) {
        return this.wishlistService.findAllByUser(req.user.userId);
    }

    @Get(':id')
    @UseGuards(JwtAuthGuard)
    async findOne(@Param('id') id: string, @Req() req: any) {
        return this.wishlistService.findOne(id, req.user.userId);
    }

    @Delete(':id')
    @UseGuards(JwtAuthGuard)
    async remove(@Param('id') id: string, @Req() req: any) {
        return this.wishlistService.remove(id, req.user.userId);
    }
}
