import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/views/auth/register/register_ctrl.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterCtrl>(
      init: RegisterCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(18)),
                              child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 36),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Create Account',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
                            ),
                            const SizedBox(height: 8),
                            Text('Join us and start managing therapy', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildLabel(context, 'Email'),
                      const SizedBox(height: 8),
                      _buildTextField(controller: ctrl.emailCtrl, hint: 'Enter your email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      _buildLabel(context, 'Password'),
                      const SizedBox(height: 8),
                      Obx(
                        () => _buildTextField(
                          controller: ctrl.passwordCtrl,
                          hint: 'Create a password (min 6 characters)',
                          icon: Icons.lock_outline,
                          obscureText: !ctrl.isPasswordVisible.value,
                          suffixIcon: ctrl.isPasswordVisible.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          onSuffixIconTap: ctrl.togglePasswordVisibility,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel(context, 'Mobile Number'),
                      const SizedBox(height: 8),
                      _buildTextField(controller: ctrl.mobileCtrl, hint: 'Enter your mobile number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, maxLength: 10),
                      const SizedBox(height: 16),
                      _buildLabel(context, 'Clinic Name'),
                      const SizedBox(height: 8),
                      _buildTextField(controller: ctrl.clinicCtrl, hint: 'Enter clinic name', icon: Icons.business_outlined),
                      const SizedBox(height: 16),
                      _buildLabel(context, 'Specialty'),
                      const SizedBox(height: 8),
                      _buildTextField(controller: ctrl.specialtyCtrl, hint: 'Enter specialty', icon: Icons.person_outline),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, size: 18, color: Color(0xFF10B981)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'By creating an account, you agree to our Terms of Service and Privacy Policy',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280), height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: ctrl.isLoading.value ? null : ctrl.register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ctrl.isLoading.value ? const Color(0xFFE5E7EB) : const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              disabledBackgroundColor: const Color(0xFFE5E7EB),
                            ),
                            child: ctrl.isLoading.value
                                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(decoration.colorScheme.onPrimary)))
                                : Text(
                                    'Create Account',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
                          TextButton(
                            onPressed: ctrl.goToLogin,
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                            child: Text(
                              'Sign In',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF10B981), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back_ios_new, size: 18), color: const Color(0xFF111827)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: const Color(0xFF111827), fontWeight: FontWeight.w500),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconTap,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffixIcon != null ? IconButton(onPressed: onSuffixIconTap, icon: Icon(suffixIcon, size: 20)).paddingOnly(right: 5) : null,
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
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
