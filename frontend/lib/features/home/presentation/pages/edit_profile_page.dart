import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _userInitials = '';
  String _userUnit = '';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await TokenService.getUserData();
    if (mounted) {
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _addressController.text = userData['address'] ?? '';
        _userUnit = userData['unit'] ?? '';
        
        final name = userData['name'] ?? '';
        if (name.isNotEmpty) {
          final parts = name.split(' ');
          if (parts.length > 1) {
            _userInitials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
          } else {
            _userInitials = name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();
          }
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final response = await AuthService.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        unit: _userUnit, // Keep existing unit
      );

      if (response['success'] == true) {
        final userData = response['data']['user'];

        if (userData != null) {
        // Retrieve current token/email to reuse
        final currentData = await TokenService.getUserData();
        
        await TokenService.saveAuthData(
          token: currentData['token'] ?? '', // Token doesn't change
          userId: userData['id']?.toString() ?? currentData['id'] ?? '',
          name: userData['name']?.toString() ?? '',
          email: userData['email']?.toString() ?? currentData['email'] ?? '',
          phone: userData['phone']?.toString(),
          address: userData['address']?.toString(),
          unit: userData['unit']?.toString(),
          createdAt: userData['createdAt']?.toString() ?? currentData['createdAt'],
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).profileUpdated),
              backgroundColor: AppColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.pop(context, true); // Return true to signal a refresh
        }
      }
      } else {
        throw Exception(response['error'] ?? AppLocalizations.of(context).failedUpdateProfile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkGrey, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).editProfile,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGrey,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE8F0EA),
                      border: Border.all(color: const Color(0xFFD5E0D8), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        _userInitials,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, size: 16, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form fields
            _buildTextField(AppLocalizations.of(context).fullName, _nameController, Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField(AppLocalizations.of(context).emailAddress, _emailController, Icons.email_outlined),
            const SizedBox(height: 16),
            _buildTextField(AppLocalizations.of(context).phoneNumber, _phoneController, Icons.phone_outlined),
            const SizedBox(height: 16),
            _buildTextField(AppLocalizations.of(context).address, _addressController, Icons.location_on_outlined),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context).saveChanges,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.darkGrey),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 13,
            color: AppColors.darkGrey.withValues(alpha: 0.4),
          ),
          prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
