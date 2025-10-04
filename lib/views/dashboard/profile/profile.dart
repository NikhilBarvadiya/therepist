import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/views/dashboard/profile/profile_ctrl.dart';
import 'package:therepist/views/dashboard/profile/settings.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileCtrl>(
      init: ProfileCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                pinned: true,
                floating: true,
                automaticallyImplyLeading: false,
                title: Text(
                  'Profile',
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                actions: [
                  if (!ctrl.isEditMode)
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.settings_outlined, color: decoration.colorScheme.primary, size: 20),
                      ),
                      onPressed: () => Get.to(() => const Settings()),
                      tooltip: 'Settings',
                    ),
                  if (!ctrl.isEditMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.edit_outlined, color: decoration.colorScheme.primary, size: 20),
                        ),
                        onPressed: ctrl.toggleEditMode,
                        tooltip: 'Edit Profile',
                      ),
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildProfileHeader(ctrl),
                      const SizedBox(height: 24),
                      _buildPersonalInfoSection(ctrl),
                      const SizedBox(height: 24),
                      _buildClinicInfoSection(ctrl),
                      if (ctrl.isEditMode) _buildEditActions(ctrl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(ProfileCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: !ctrl.isEditMode ? null : () => ctrl.pickAvatar(),
            child: Stack(
              children: [
                Obx(() {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      image: ctrl.avatar.value != null && ctrl.avatar.value!.path.isNotEmpty ? DecorationImage(image: FileImage(ctrl.avatar.value!), fit: BoxFit.cover) : null,
                    ),
                    child: ctrl.avatar.value == null || ctrl.avatar.value!.path.isEmpty ? Icon(Icons.person, size: 40, color: Colors.white) : null,
                  );
                }),
                if (ctrl.isEditMode)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.camera_alt, size: 16, color: decoration.colorScheme.primary),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ctrl.isEditMode)
                  _buildEditTextField(ctrl.nameController, 'Full Name')
                else
                  Obx(
                    () => Text(
                      ctrl.user.value.name,
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                const SizedBox(height: 8),
                if (ctrl.isEditMode)
                  _buildEditTextField(ctrl.emailController, 'Email Address', isEmail: true)
                else
                  Obx(() => Text(ctrl.user.value.email, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.9)))),
                const SizedBox(height: 8),
                if (!ctrl.isEditMode) Obx(() => Text(ctrl.user.value.specialty, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.8)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(ProfileCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 6),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: decoration.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
          ),
          if (ctrl.isEditMode) ...[
            _buildEditField('Full Name', ctrl.nameController, Icons.person_2_rounded),
            _buildEditField('Email Address', ctrl.emailController, Icons.email_rounded, isEmail: true),
            _buildEditField('Mobile Number', ctrl.mobileController, Icons.phone_outlined, isPhone: true),
            _buildEditField('Specialty', ctrl.specialtyController, Icons.medical_services_outlined),
            _buildEditField('Experience (Years)', ctrl.experienceController, Icons.work_history_outlined, isNumber: true),
          ] else ...[
            _buildInfoTile(Icons.phone_outlined, 'Mobile', ctrl.user.value.mobile),
            _buildInfoTile(Icons.medical_services_outlined, 'Specialty', ctrl.user.value.specialty),
            _buildInfoTile(Icons.work_history_outlined, 'Experience', '${ctrl.user.value.experienceYears} Years'),
          ],
        ],
      ),
    );
  }

  Widget _buildClinicInfoSection(ProfileCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 6),
            child: Row(
              children: [
                Icon(Icons.business_outlined, color: decoration.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Clinic Information',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
          ),
          if (ctrl.isEditMode) ...[
            _buildEditField('Clinic Name', ctrl.clinicNameController, Icons.business_outlined),
            _buildEditField('Clinic Address', ctrl.clinicAddressController, Icons.location_on_outlined, maxLines: 2),
          ] else ...[
            _buildInfoTile(Icons.business_outlined, 'Clinic Name', ctrl.user.value.clinicName),
            _buildInfoTile(Icons.location_on_outlined, 'Clinic Address', ctrl.user.value.clinicAddress),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: decoration.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon, {bool isPhone = false, bool isNumber = false, bool isEmail = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: decoration.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  keyboardType: isPhone
                      ? TextInputType.phone
                      : isNumber
                      ? TextInputType.number
                      : isEmail
                      ? TextInputType.emailAddress
                      : TextInputType.text,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: decoration.colorScheme.primary, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditTextField(TextEditingController controller, String hintText, {bool isEmail = false}) {
    return TextField(
      readOnly: true,
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.black.withOpacity(0.7), fontSize: 14),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        isDense: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: decoration.colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildEditActions(ProfileCtrl ctrl) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: ctrl.toggleEditMode,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.grey[700]),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: ctrl.saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: decoration.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Save Changes',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
