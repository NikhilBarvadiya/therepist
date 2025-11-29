import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/utils/routes/route_name.dart';
import 'package:therepist/views/dashboard/profile/profile_ctrl.dart';
import 'package:therepist/views/dashboard/profile/ui/availability_settings.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileCtrl>();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: decoration.colorScheme.primary,
            pinned: true,
            floating: true,
            title: Text('Settings', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
            leading: IconButton(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
              ),
              icon: Icon(Icons.arrow_back, color: decoration.colorScheme.primary, size: 20),
              onPressed: () => Get.close(1),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Account Settings'),
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    children: [
                      _buildSettingsTile(icon: Icons.lock_outline, title: 'Change Password', subtitle: 'Update your account password', onTap: () => _showChangePasswordDialog(ctrl)),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'Notification Range',
                        subtitle: 'Set distance for receiving orders',
                        onTap: () => _showNotificationRangeDialog(ctrl),
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.calendar_today_outlined,
                        title: 'Clinic Availability',
                        subtitle: 'Set your working hours and slots',
                        onTap: () => Get.to(() => const AvailabilitySettings()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Security & Privacy'),
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'How we protect your data',
                        onTap: () => _showPolicyPage('Privacy Policy', _privacyPolicyContent),
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Terms & Conditions',
                        subtitle: 'App usage guidelines',
                        onTap: () => _showPolicyPage('Terms & Conditions', _termsContent),
                      ),
                      _buildDivider(),
                      _buildSettingsTile(icon: Icons.help_outline, title: 'Help & Support', subtitle: 'Get help using the app', onTap: () => _showPolicyPage('Help & Support', _helpContent)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Account Actions'),
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    children: [
                      _buildSettingsTile(icon: Icons.logout_outlined, title: 'Logout', subtitle: 'Sign out of your account', color: Colors.orange, onTap: () => _showLogoutDialog(ctrl)),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.delete_forever_outlined,
                        title: 'Delete Account',
                        subtitle: 'Permanently remove your account',
                        color: Colors.red,
                        onTap: () => _showDeleteAccountDialog(ctrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('About App'),
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    children: [
                      _buildSettingsTile(icon: Icons.info_outline, title: 'Version', subtitle: '1.0.0 (Build 123)', onTap: () {}),
                      _buildDivider(),
                      _buildSettingsTile(icon: Icons.update_outlined, title: 'Check for Updates', subtitle: 'Latest version available', onTap: _checkForUpdates),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildAppFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required String subtitle, VoidCallback? onTap, Color? color}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: (color ?? decoration.colorScheme.primary).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color ?? decoration.colorScheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: color ?? Colors.black87),
      ),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }

  Widget _buildAppFooter() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: decoration.colorScheme.primary, borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.medical_services, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            'Therapist Pro',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text('Version 1.0.0 • © 2024', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 4),
          Text(
            'Empowering Therapists, healing patients',
            style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(ProfileCtrl ctrl) {
    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.lock_reset, color: decoration.colorScheme.primary, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Change Password',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your current and new password',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: ctrl.currentPasswordController,
                    label: 'Current Password',
                    isVisible: ctrl.isCurrentPasswordVisible.value,
                    onToggleVisibility: () {
                      ctrl.toggleCurrentPasswordVisibility();
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: ctrl.newPasswordController,
                    label: 'New Password',
                    isVisible: ctrl.isNewPasswordVisible.value,
                    onToggleVisibility: () {
                      ctrl.toggleNewPasswordVisibility();
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: ctrl.confirmPasswordController,
                    label: 'Confirm New Password',
                    isVisible: ctrl.isConfirmPasswordVisible.value,
                    onToggleVisibility: () {
                      ctrl.toggleConfirmPasswordVisibility();
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.close(1),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ctrl.changePassword(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: decoration.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: ctrl.isSaving.value
                                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(
                                    'Update',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordField({required TextEditingController controller, required String label, required bool isVisible, required VoidCallback onToggleVisibility}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: "******",
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey[500]),
              onPressed: onToggleVisibility,
            ).paddingOnly(right: 5),
          ),
        ),
      ],
    );
  }

  void _showNotificationRangeDialog(ProfileCtrl ctrl) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.location_on_outlined, color: decoration.colorScheme.primary, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Notification Range',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Set maximum distance to receive order notifications',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Obx(
                () => Column(
                  children: [
                    Text(
                      '${ctrl.notificationRange.value} km',
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: decoration.colorScheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: ctrl.notificationRange.value.toDouble(),
                      min: 1,
                      max: 50,
                      divisions: 49,
                      activeColor: decoration.colorScheme.primary,
                      inactiveColor: Colors.grey[300],
                      label: '${ctrl.notificationRange.value} km',
                      onChanged: (value) => ctrl.setNotificationRange(value.toInt()),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1 km', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                        Text('50 km', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.close(1),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ctrl.updateNotificationRange();
                        Get.close(1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: decoration.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPolicyPage(String title, String content) {
    Get.to(
      () => Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: decoration.colorScheme.primary,
          title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)),
          leading: IconButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
              backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
            ),
            icon: Icon(Icons.arrow_back, color: decoration.colorScheme.primary, size: 20),
            onPressed: () => Get.close(1),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Text(content, style: GoogleFonts.poppins(fontSize: 14, height: 1.6, color: Colors.grey[800])),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(ProfileCtrl ctrl) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.logout_rounded, color: Colors.orange, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Logout',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to logout from your account?',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.close(1),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ctrl.logout();
                        Get.offAllNamed(AppRouteNames.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(ProfileCtrl ctrl) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.delete_forever_rounded, color: Colors.red, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete Account',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone. All your data will be permanently deleted.',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.close(1),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ctrl.deleteAccount();
                        Get.offAllNamed(AppRouteNames.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkForUpdates() {
    Get.snackbar('Update Check', 'You have the latest version of Therapist Pro', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
  }

  final String _privacyPolicyContent = '''
At Therapist Pro, we are committed to protecting your privacy. This policy outlines how we collect, use, and safeguard your personal information. 

**Data Collection**
We collect only necessary data, such as name, email, and address, to provide physiotherapy services.

**Data Usage**
Your information is used to manage appointments, services, and communication.

**Data Protection**
We use encryption and secure storage to protect your data.

**Sharing**
We do not share your data with third parties without consent.

For more details, contact us at support@therapistpro.com.
  ''';

  final String _termsContent = '''
By using Therapist Pro, you agree to the following terms:

**Usage**
The app is for physiotherapy-related services only.

**Account**
You are responsible for maintaining the security of your account.

**Liability**
We are not liable for any misuse of the app.

**Updates**
These terms may be updated periodically.

For full terms, contact us at support@therapistpro.com.
  ''';

  final String _helpContent = '''
**Getting Started**
- Set up your profile with accurate information
- Add your services and set availability
- Manage appointments through the dashboard

**Common Issues**
- For login issues, try resetting your password
- Ensure stable internet connection
- Update app to latest version

**Contact Support**
Email: support@therapistpro.com
Phone: +1-555-0123
Hours: Mon-Fri, 9AM-6PM

We're here to help you succeed!
  ''';
}
