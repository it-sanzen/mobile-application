import axios from 'axios';
import FormData from 'form-data';
import * as fs from 'fs';
import * as path from 'path';
import 'dotenv/config';

async function run() {
    try {
        console.log("Starting Text-to-Image...");
        const textToImageFormData = new FormData();
        textToImageFormData.append('prompt', 'a beautiful bush');
        textToImageFormData.append('output_format', 'png');

        const imageResponse = await axios.post(
            'https://api.stability.ai/v2beta/stable-image/generate/core',
            textToImageFormData,
            {
                headers: {
                    ...textToImageFormData.getHeaders(),
                    'Authorization': `Bearer ${process.env.STABILITY_API_KEY}`,
                    'Accept': 'image/*'
                },
                responseType: 'arraybuffer',
                validateStatus: undefined,
            }
        );

        console.log("Image Generation Status:", imageResponse.status);
        if (imageResponse.status !== 200) {
            console.error("Image Error:", imageResponse.data.toString());
            return;
        }

        const tempPath = path.resolve('temp_test_image.png');
        fs.writeFileSync(tempPath, Buffer.from(imageResponse.data));
        console.log("Saved temporary image directly to disk.");

        console.log("Starting Image-to-3D...");
        const imageTo3DFormData = new FormData();
        imageTo3DFormData.append('image', fs.createReadStream(tempPath));

        const fast3dResponse = await axios.post(
            'https://api.stability.ai/v2beta/3d/stable-fast-3d',
            imageTo3DFormData,
            {
                headers: {
                    ...imageTo3DFormData.getHeaders(),
                    'Authorization': `Bearer ${process.env.STABILITY_API_KEY}`,
                },
                responseType: 'arraybuffer',
            }
        );

        console.log("3D Data Length:", fast3dResponse.data.length);
        fs.unlinkSync(tempPath);
    } catch (error: any) {
        console.error("PIPELINE ERROR:");
        console.error(error.response?.data?.toString() || error.message);
    }
}

run();
