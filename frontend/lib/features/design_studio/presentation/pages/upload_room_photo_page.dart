import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import 'ai_redesign_simulator_page.dart';

class UploadRoomPhotoPage extends StatefulWidget {
  const UploadRoomPhotoPage({super.key});

  @override
  State<UploadRoomPhotoPage> createState() => _UploadRoomPhotoPageState();
}

class _UploadRoomPhotoPageState extends State<UploadRoomPhotoPage> {
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      debugPrint('Attempting to pick image from $source');
      final XFile? image = await _picker.pickImage(source: source);
      debugPrint('Image picked: ${image?.path}');
      
      // If the user picked an image (or took a photo), proceed to simulate upload
      if (image != null && mounted) {
        debugPrint('Image valid and widget mounted. Going to Simulator...');
        _navigateToSimulator(image);
      } else {
        debugPrint('Image was null or widget not mounted.');
      }
    } catch (e) {
      debugPrint('Error in _pickImage: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing camera/gallery: $e')),
        );
      }
    }
  }

  void _navigateToSimulator(XFile imageFile) async {
    final savedImage = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(builder: (_) => AiRedesignSimulatorPage(imageFile: imageFile)),
    );
    
    // If the simulator returns a saved design (e.g., URL or original photo), pop back to Gallery
    if (savedImage != null && mounted) {
      Navigator.pop(context, savedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text(
          'Sanzen Creative Studio',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 24),
              const Text(
                'Upload Your Room Photo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Take a photo of your empty room, or a room you want to redesign. Our AI will analyze the dimensions and instantly generate a photorealistic image showing your room fully furnished in different styles.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.darkGrey.withValues(alpha: 0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (_isUploading)
                Column(
                  children: [
                    const CircularProgressIndicator(color: AppColors.primaryGreen),
                    const SizedBox(height: 24),
                    Text(
                      'AI is analyzing your room dimensions...\nGenerating photorealistic redesigns...',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppColors.primaryGreen.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library, color: AppColors.white),
                        label: const Text(
                          'Choose from Gallery',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, color: AppColors.primaryGreen),
                        label: const Text(
                          'Take a Photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
