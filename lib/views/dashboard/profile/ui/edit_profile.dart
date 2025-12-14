import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:therepist/utils/config/session.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/utils/network/api_config.dart';
import 'package:therepist/utils/storage.dart';
import 'package:therepist/utils/toaster.dart';
import 'package:therepist/views/auth/auth_service.dart';
import 'package:therepist/views/dashboard/home/home_ctrl.dart';
import 'package:therepist/views/dashboard/profile/profile_ctrl.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final ProfileCtrl ctrl = Get.find<ProfileCtrl>();
  final AuthService _authService = Get.find<AuthService>();
  final _formKey = GlobalKey<FormState>();

  bool _hasChanges = false, _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _specialtyController;
  late TextEditingController _experienceController;
  late TextEditingController _clinicNameController;
  late TextEditingController _clinicAddressController;

  File? _selectedAvatar;
  String? _initialAvatarUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: ctrl.user.value.name);
    _emailController = TextEditingController(text: ctrl.user.value.email);
    _mobileController = TextEditingController(text: ctrl.user.value.mobile);
    _specialtyController = TextEditingController(text: ctrl.user.value.specialty);
    _experienceController = TextEditingController(text: ctrl.user.value.experienceYears.toString());
    _clinicNameController = TextEditingController(text: ctrl.user.value.clinicName);
    _clinicAddressController = TextEditingController(text: ctrl.user.value.clinicAddress);
    _initialAvatarUrl = ctrl.user.value.avatar;

    _nameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _mobileController.addListener(_checkForChanges);
    _specialtyController.addListener(_checkForChanges);
    _experienceController.addListener(_checkForChanges);
    _clinicNameController.addListener(_checkForChanges);
    _clinicAddressController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    final hasTextChanges =
        _nameController.text != ctrl.user.value.name ||
        _emailController.text != ctrl.user.value.email ||
        _mobileController.text != ctrl.user.value.mobile ||
        _specialtyController.text != ctrl.user.value.specialty ||
        _experienceController.text != ctrl.user.value.experienceYears.toString() ||
        _clinicNameController.text != ctrl.user.value.clinicName ||
        _clinicAddressController.text != ctrl.user.value.clinicAddress;
    final hasAvatarChange = _selectedAvatar != null;
    setState(() {
      _hasChanges = hasTextChanges || hasAvatarChange;
    });
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) {
      return true;
    }
    final result = await showDialog<bool>(context: context, barrierDismissible: false, builder: (context) => _buildDiscardChangesDialog());
    return result ?? false;
  }

  Widget _buildDiscardChangesDialog() {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700, size: 24),
          const SizedBox(width: 12),
          Text(
            'Discard Changes?',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
        ],
      ),
      content: Text('You have unsaved changes. Are you sure you want to leave?', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text('Discard', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Future<void> _pickAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) {
      setState(() {
        _selectedAvatar = File(image.path);
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      setState(() {
        _isSaving = true;
      });
      final request = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'specialty': _specialtyController.text.trim(),
        'experience': int.tryParse(_experienceController.text.trim()) ?? 0,
        'clinicName': _clinicNameController.text.trim(),
        'clinicAddress': _clinicAddressController.text.trim(),
        'notificationRange': ctrl.notificationRange.value,
        'type': ctrl.user.value.type,
        'address': ctrl.user.value.clinicAddress,
        'coordinates': ctrl.user.value.location.coordinates,
      };
      dio.FormData formData = dio.FormData.fromMap(request);
      if (_selectedAvatar != null) {
        formData.files.add(MapEntry('profileImage', await dio.MultipartFile.fromFile(_selectedAvatar!.path, filename: path.basename(_selectedAvatar!.path))));
      }
      final response = await _authService.updateProfile(formData);
      if (response != null) {
        await write(AppSession.userData, response);
        await ctrl.loadLocalData();
        final homeCtrl = Get.find<HomeCtrl>();
        homeCtrl.getUserProfile();
        toaster.success('Profile updated successfully');
        await Future.delayed(const Duration(milliseconds: 500));
        Get.close(1);
      }
    } catch (e) {
      toaster.error('Error updating profile: ${e.toString()}');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: decoration.colorScheme.primary,
          leading: IconButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
              backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
            ),
            icon: Icon(Icons.arrow_back, color: decoration.colorScheme.primary),
            onPressed: () async {
              final canPop = await _onWillPop();
              if (canPop && mounted) {
                Get.close(1);
              }
            },
          ),
          title: Text('Edit Profile', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              onPressed: ctrl.isGettingLocation.value ? null : ctrl.retryLocation,
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(8),
              ),
              icon: Obx(() {
                if (ctrl.isGettingLocation.value) {
                  return SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: decoration.colorScheme.primary));
                }
                return Icon(Icons.location_on, size: 20, color: decoration.colorScheme.primary);
              }),
              tooltip: 'Update Location',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(children: [_buildAvatarSection(), const SizedBox(height: 32), _buildPersonalInfoForm(), const SizedBox(height: 24), _buildClinicInfoForm(), const SizedBox(height: 32)]),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
          ),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _hasChanges && !_isSaving ? _saveProfile : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasChanges && !_isSaving ? decoration.colorScheme.primary : const Color(0xFFE5E7EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                disabledBackgroundColor: const Color(0xFFE5E7EB),
              ),
              child: _isSaving
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(decoration.colorScheme.onPrimary)))
                  : Text(
                      'Save Changes',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _hasChanges ? Colors.white : Colors.grey.shade400),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: decoration.colorScheme.primary.withOpacity(0.2), width: 3),
              ),
              child: ClipOval(
                child: _selectedAvatar != null
                    ? Image.file(_selectedAvatar!, fit: BoxFit.cover)
                    : _initialAvatarUrl != null && _initialAvatarUrl!.isNotEmpty
                    ? Image.network(
                        APIConfig.resourceBaseURL + _initialAvatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Icon(Icons.person, size: 40, color: Colors.grey.shade400),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.person, size: 40, color: Colors.grey.shade400),
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: decoration.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Tap to change profile photo', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildPersonalInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Personal Information'),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _nameController,
          hint: 'Enter your full name',
          icon: Icons.person_outline,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          hint: 'Enter your email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!GetUtils.isEmail(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _mobileController,
          hint: 'Enter your mobile number',
          icon: Icons.phone_outlined,
          maxLength: 10,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your mobile number';
            }
            if (!GetUtils.isPhoneNumber(value) || value.length != 10) {
              return 'Please enter a valid 10-digit mobile number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _specialtyController,
          hint: 'Enter your specialty',
          icon: Icons.medical_services_outlined,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your specialty';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _experienceController,
          hint: 'Enter your experience (years)',
          icon: Icons.work_history_outlined,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your experience';
            }
            final experience = int.tryParse(value);
            if (experience == null || experience < 0 || experience > 50) {
              return 'Please enter valid experience (0-50 years)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildClinicInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Clinic Information'),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _clinicNameController,
          hint: 'Enter clinic name',
          icon: Icons.business_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter clinic name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _clinicAddressController,
          hint: 'Enter clinic address',
          icon: Icons.location_on_outlined,
          maxLines: 3,
          textCapitalization: TextCapitalization.words,
          suffixLoading: ctrl.isGettingLocation.value,
          suffixIcon: ctrl.isGettingLocation.value ? Icons.location_searching : Icons.location_on,
          onSuffixIconTap: ctrl.isGettingLocation.value ? null : ctrl.retryLocation,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter clinic address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool suffixLoading = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: 1,
      textCapitalization: textCapitalization,
      style: const TextStyle(fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        prefixIcon: Icon(icon, size: 20, color: decoration.colorScheme.primary),
        suffixIcon: suffixIcon != null || suffixLoading
            ? suffixLoading
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(decoration.colorScheme.primary))).paddingOnly(right: 15)
                  : IconButton(
                      onPressed: onSuffixIconTap,
                      icon: Icon(suffixIcon, size: 20, color: decoration.colorScheme.primary),
                    ).paddingOnly(right: 5)
            : null,
        suffixIconConstraints: suffixLoading == true ? const BoxConstraints(minWidth: 0, minHeight: 0, maxWidth: 50, maxHeight: 24) : null,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: decoration.colorScheme.primary, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
