import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AiDesignerService {
    constructor(private prisma: PrismaService) { }

    async generateDesign(
        userId: string,
        sourceImageUrl: string,
        roomType: string,
        designStyle: string,
        isMocking: boolean
    ): Promise<{ message: string; savedDesign: any }> {
        try {
            let finalImageUrl = sourceImageUrl;

            if (isMocking) {
                // 1. Simulate the time it takes an AI API to process an image (5 seconds)
                await new Promise(resolve => setTimeout(resolve, 5000));

                // 2. In a real integration, we upload the AI output to an S3 bucket and return that URL.
                // For the mock, we just return the URL of the exact image the user submitted.
                finalImageUrl = sourceImageUrl;
            } else {
                // TODO: When user purchases a SofaBrain api key, implement real image-to-image pipeline here:
                // const aiResponse = await axios.post('sofabrain/api', { image: sourceImageUrl });
                // finalImageUrl = aiResponse.data.url;
            }

            // 3. Save the resulting design to the database so it appears in "My Designs"
            const savedDesign = await this.prisma.savedDesign.create({
                data: {
                    userId,
                    imageUrl: finalImageUrl,
                    roomType,
                    designStyle,
                }
            });

            return {
                message: "Design explicitly generated and saved successfully.",
                savedDesign
            };
        } catch (error) {
            console.error('Error generating AI design:', error);
            throw new InternalServerErrorException('Failed to generate design pipeline.');
        }
    }
    async getMyDesigns(userId: string) {
        return this.prisma.savedDesign.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
        });
    }

    async deleteDesign(userId: string, designId: string) {
        // Find the design first to ensure it belongs to the user
        const design = await this.prisma.savedDesign.findUnique({
            where: { id: designId }
        });

        if (!design || design.userId !== userId) {
            throw new InternalServerErrorException('Design not found or unauthorized');
        }

        return this.prisma.savedDesign.delete({
            where: { id: designId }
        });
    }
}
