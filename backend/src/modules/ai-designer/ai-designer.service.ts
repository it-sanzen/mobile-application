import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import OpenAI from 'openai';
import * as fs from 'fs';
import * as path from 'path';
import axios from 'axios';
import FormData from 'form-data';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class AiDesignerService {
    constructor(private prisma: PrismaService) { }

    async generate3DObject(
        userId: string,
        sourceImagePath: string,
    ): Promise<{ message: string; savedDesign: any }> {
        try {
            if (!process.env.STABILITY_API_KEY) {
                throw new InternalServerErrorException('STABILITY_API_KEY is missing from .env');
            }

            // We must read the file from disk so we can attach it to form-data
            // The image path actually comes from Multer, e.g., 'uploads/ai-designs/filename.png'
            const absoluteImagePath = path.resolve(sourceImagePath);

            if (!fs.existsSync(absoluteImagePath)) {
                throw new InternalServerErrorException('Uploaded source image not found on disk.');
            }

            const formData = new FormData();
            formData.append('image', fs.createReadStream(absoluteImagePath));

            // Call Stability AI's Fast 3D API
            const response = await axios.post(
                'https://api.stability.ai/v2beta/3d/stable-fast-3d',
                formData,
                {
                    headers: {
                        ...formData.getHeaders(),
                        'Authorization': `Bearer ${process.env.STABILITY_API_KEY}`,
                    },
                    responseType: 'arraybuffer', // Crucial for receiving binary .glb data
                }
            );

            // Construct new 3D filename
            const glbFilename = `${path.parse(absoluteImagePath).name}.glb`;
            const glbSavePath = path.join('./uploads/ai-designs', glbFilename);

            // Save the binary .glb data to disk
            fs.writeFileSync(glbSavePath, Buffer.from(response.data));

            // Determine the public URL (same logic as images)
            const baseUrl = process.env.BACKEND_URL || `http://127.0.0.1:3000`;
            const finalGlbUrl = `${baseUrl}/uploads/ai-designs/${glbFilename}`;

            const savedDesign = await this.prisma.savedDesign.create({
                data: {
                    userId,
                    imageUrl: finalGlbUrl, // Repurposing this column for the .glb URL
                    roomType: "AI Generated 3D Object",
                    designStyle: "Stable Fast 3D",
                }
            });

            return {
                message: "3D Object explicitly generated and saved successfully.",
                savedDesign
            };

        } catch (error: any) {
            console.error('STABILITY API TRACE:', error?.response?.data || error.message || error);
            throw new InternalServerErrorException('Failed to generate 3D pipeline.');
        }
    }

    async generate3DObjectFromText(
        userId: string,
        prompt: string,
    ): Promise<{ message: string; savedDesign: any }> {
        try {
            console.log(`Phase 2: Local 3D Asset Resolution Triggered for prompt: "${prompt}"`);

            // Maintain a small, extremely high-quality dictionary of open-source CORS-friendly .glb links
            // These simulate the AI text-to-3D return mapping natively and instantly for free
            const assetLibrary = [
                { keyword: 'bush', url: 'https://raw.githubusercontent.com/mrdoob/three.js/master/examples/models/gltf/Flower/Flower.glb' },
                { keyword: 'tree', url: 'https://raw.githubusercontent.com/mrdoob/three.js/master/examples/models/gltf/Flower/Flower.glb' },
                { keyword: 'plant', url: 'https://raw.githubusercontent.com/mrdoob/three.js/master/examples/models/gltf/Flower/Flower.glb' },
                { keyword: 'table', url: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Box/glTF-Binary/Box.glb' },
                { keyword: 'bed', url: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Box/glTF-Binary/Box.glb' },
                { keyword: 'duck', url: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Binary/Duck.glb' },
                { keyword: 'sofa', url: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/GlamVelvetSofa/glTF-Binary/GlamVelvetSofa.glb' },
                { keyword: 'couch', url: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/GlamVelvetSofa/glTF-Binary/GlamVelvetSofa.glb' },
                { keyword: 'car', url: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/ToyCar/glTF-Binary/ToyCar.glb' },
                { keyword: 'helmet', url: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/FlightHelmet/glTF-Binary/FlightHelmet.glb' },
            ];

            const lowerPrompt = prompt.toLowerCase();
            let finalGlbUrl = 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Binary/Duck.glb'; // Default fallback

            for (const asset of assetLibrary) {
                if (lowerPrompt.includes(asset.keyword)) {
                    finalGlbUrl = asset.url;
                    break;
                }
            }

            // Step 3: Save to the user's library
            const savedDesign = await this.prisma.savedDesign.create({
                data: {
                    userId,
                    imageUrl: finalGlbUrl, // Repurposing this column for the direct .glb URL 
                    roomType: "AI Search Pipeline",
                    designStyle: prompt.substring(0, 100),
                }
            });

            return {
                message: "3D Object found and loaded successfully.",
                savedDesign
            };
        } catch (error: any) {
            console.error('ASSET RESOLUTION ERROR:', error.message || error);
            throw new InternalServerErrorException(error.message || 'Failed to load 3D asset.');
        }
    }

    async getMyDesigns(userId: string) {
        return this.prisma.savedDesign.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
        });
    }

    async deleteDesign(userId: string, designId: string) {
        try {
            // Find the design first to ensure it belongs to the user
            const design = await this.prisma.savedDesign.findUnique({
                where: { id: designId }
            });

            if (!design || design.userId !== userId) {
                throw new InternalServerErrorException('Design not found or unauthorized');
            }

            return await this.prisma.savedDesign.delete({
                where: { id: designId }
            });
        } catch (error: any) {
            console.error('DELETE DESIGN ERROR:', error.message || error);
            throw new InternalServerErrorException(error.message || 'Failed to delete design');
        }
    }
}
