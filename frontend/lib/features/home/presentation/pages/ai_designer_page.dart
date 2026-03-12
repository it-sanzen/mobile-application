import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'dart:async';

class AiDesignerPage extends StatefulWidget {
  const AiDesignerPage({super.key});

  @override
  State<AiDesignerPage> createState() => _AiDesignerPageState();
}

class _AiDesignerPageState extends State<AiDesignerPage> {
  String? _selectedRoom;
  String? _selectedTheme;
  bool _isGenerating = false;
  String? _generatedImageUrl;

  final List<String> _rooms = ['Kitchen', 'Bedroom', 'Living Room', 'Bathroom', 'Office'];
  final List<String> _themes = ['Modern Luxury', 'Minimalist', 'Industrial', 'Classic', 'Sanzen Signature'];

  // Map selections to our generated mockups
  String _getMockupPath(String room, String theme) {
    if (room == 'Kitchen') {
      return 'assets/images/ai_designer/kitchen.png';
    } else if (room == 'Bedroom') {
      return 'assets/images/ai_designer/bedroom.png';
    } else {
      // Fallback for living room, bathroom, office etc.
      return 'assets/images/ai_designer/living_room.png';
    }
  }

  void _generateDesign() {
    if (_selectedRoom == null || _selectedTheme == null) return;
    
    setState(() => _isGenerating = true);
    
    // Simulate AI Generation time
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _generatedImageUrl = _getMockupPath(_selectedRoom!, _selectedTheme!);
        });
      }
    });
  }

  void _resetDesigner() {
    setState(() {
      _selectedRoom = null;
      _selectedTheme = null;
      _isGenerating = false;
      _generatedImageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text(
          'Visual AI Designer',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isGenerating) {
      return _buildGeneratingState();
    } else if (_generatedImageUrl != null) {
      return _buildResultState();
    } else {
      return _buildSelectionState();
    }
  }

  Widget _buildSelectionState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What room are you designing?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.black),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _rooms.length,
                  itemBuilder: (context, index) {
                    final room = _rooms[index];
                    final isSelected = _selectedRoom == room;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedRoom = room),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryGreen : AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryGreen : AppColors.grey.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 2)
                          ] : null,
                        ),
                        child: Center(
                          child: Text(
                            room,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.white : AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),
                const Text(
                  'Select your aesthetic',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.black),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _themes.map((theme) {
                    final isSelected = _selectedTheme == theme;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTheme = theme),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.gold : AppColors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected ? AppColors.gold : AppColors.grey.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          theme,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.white : AppColors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_selectedRoom != null && _selectedTheme != null) ? _generateDesign : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Generate AI Design',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneratingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: AppColors.gold,
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Sanzen AI is designing...',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 12),
          Text(
            'Applying $_selectedTheme style to your $_selectedRoom',
            style: TextStyle(fontSize: 16, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState() {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: AppColors.black,
            child: Image.asset(
              _generatedImageUrl!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5))
            ],
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_selectedTheme $_selectedRoom',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.black),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'AI Generated',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetDesigner,
                        icon: const Icon(Icons.refresh, color: AppColors.black),
                        label: const Text('Redesign', style: TextStyle(color: AppColors.black)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.grey, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Mock save to gallery
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Image saved to gallery!'), backgroundColor: AppColors.success),
                          );
                        },
                        icon: const Icon(Icons.download, color: AppColors.white),
                        label: const Text('Save HD', style: TextStyle(color: AppColors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
