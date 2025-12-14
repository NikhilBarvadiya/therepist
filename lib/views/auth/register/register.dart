import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/views/auth/register/register_ctrl.dart';
import 'package:therepist/views/auth/register/ui/multi_selection_bottom_sheet.dart';

import '../../../models/service_model.dart' show ServiceModel;

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
                      _buildSectionHeader('Personal Information'),
                      const SizedBox(height: 16),
                      _buildLabel(context, 'Name'),
                      const SizedBox(height: 8),
                      _buildTextField(controller: ctrl.nameCtrl, hint: 'Enter your name', textCapitalization: TextCapitalization.words, icon: Icons.person_2_rounded),
                      const SizedBox(height: 16),
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
                      _buildTextField(
                        controller: ctrl.mobileCtrl,
                        hint: '+91 Enter your mobile number',
                        icon: Icons.phone_outlined,
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\+91')), FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                      ),
                      const SizedBox(height: 16),
                      _buildLabel(context, 'Address'),
                      const SizedBox(height: 8),
                      Obx(
                        () => _buildTextField(
                          controller: ctrl.addressCtrl,
                          hint: 'Enter your address',
                          icon: Icons.home_outlined,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.words,
                          suffixLoading: ctrl.isGettingLocation.value,
                          suffixIcon: ctrl.isGettingLocation.value ? Icons.location_searching : Icons.location_on,
                          onSuffixIconTap: ctrl.isGettingLocation.value ? null : ctrl.retryLocation,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Professional Information'),
                      const SizedBox(height: 16),
                      _buildLabel(context, 'Clinic Name'),
                      const SizedBox(height: 8),
                      _buildTextField(controller: ctrl.clinicCtrl, hint: 'Enter clinic name', icon: Icons.business_outlined),
                      const SizedBox(height: 16),
                      _buildLabel(context, 'Specialty'),
                      const SizedBox(height: 8),
                      _buildTextField(controller: ctrl.specialtyCtrl, hint: 'Enter specialty', textCapitalization: TextCapitalization.words, icon: Icons.person_outline),
                      const SizedBox(height: 16),
                      _buildLabel(context, 'Experience (Years)'),
                      const SizedBox(height: 8),
                      _buildExperienceField(ctrl),
                      const SizedBox(height: 16),
                      _buildLabel(context, 'Practitioner Type'),
                      const SizedBox(height: 8),
                      _buildTypeField(context, ctrl),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Services & Equipment'),
                      const SizedBox(height: 16),
                      _buildLabel(context, 'Services Offered'),
                      const SizedBox(height: 8),
                      _buildEnhancedMultiSelectField(
                        context: context,
                        items: ctrl.services,
                        selectedItems: ctrl.selectedServices,
                        hint: 'Select services you offer',
                        icon: Icons.medical_services_outlined,
                        onTap: () => _showServicesSelection(context, ctrl),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel(context, 'Available Equipment'),
                      const SizedBox(height: 8),
                      _buildEnhancedMultiSelectField(
                        context: context,
                        items: ctrl.equipment,
                        selectedItems: ctrl.selectedEquipment,
                        hint: 'Select available equipment',
                        icon: Icons.fitness_center_outlined,
                        onTap: () => _showEquipmentSelection(context, ctrl),
                      ),
                      const SizedBox(height: 24),
                      Obx(() => _buildRegisterButton(ctrl, context)),
                      const SizedBox(height: 24),
                      _buildTermsAgreement(context),
                      const SizedBox(height: 24),
                      _buildLoginRedirect(context, ctrl),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                _buildBackButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExperienceField(RegisterCtrl ctrl) {
    return TextFormField(
      maxLength: 2,
      controller: ctrl.experienceCtrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        counterText: '',
        hintText: 'Enter years of experience',
        prefixIcon: const Icon(Icons.work_history_rounded, size: 20, color: Color(0xFF10B981)),
        suffixText: 'years',
        suffixStyle: const TextStyle(color: Color(0xFF6B7280)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter experience';
        }
        final years = int.tryParse(value);
        if (years == null || years < 0 || years > 50) {
          return 'Please enter valid experience (0-50 years)';
        }
        return null;
      },
    );
  }

  Widget _buildTypeField(BuildContext context, RegisterCtrl ctrl) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            _buildTypeOption(
              context: context,
              title: 'Regular Practitioner',
              subtitle: 'Full professional with complete practice rights',
              value: 'Regular',
              groupValue: ctrl.practitionerType.value,
              onChanged: (value) => ctrl.setPractitionerType(value!),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            _buildTypeOption(
              context: context,
              title: 'Intern',
              subtitle: 'Training or under supervision',
              value: 'Intern',
              groupValue: ctrl.practitionerType.value,
              onChanged: (value) => ctrl.setPractitionerType(value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String value,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = groupValue == value;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: const Color(0xFF10B981), width: 1.5) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? const Color(0xFF10B981) : const Color(0xFFD1D5DB), width: 2),
                color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF10B981) : const Color(0xFF111827)),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: isSelected ? const Color(0xFF10B981).withOpacity(0.8) : const Color(0xFF6B7280))),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
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
    bool suffixLoading = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconTap,
    int? maxLength,
    int maxLines = 1,
    Iterable<String>? autofillHints,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: 1,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      style: TextStyle(fontSize: 14, letterSpacing: .5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, letterSpacing: .5, color: Colors.grey.shade400),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildEnhancedMultiSelectField({
    required BuildContext context,
    required RxList<ServiceModel> items,
    required RxList<ServiceModel> selectedItems,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Obx(
      () => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selectedItems.isEmpty ? const Color(0xFFE5E7EB) : const Color(0xFF10B981).withOpacity(0.3), width: selectedItems.isEmpty ? 1 : 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF10B981)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedItems.isEmpty ? hint : '${selectedItems.length} item${selectedItems.length > 1 ? 's' : ''} selected',
                      style: TextStyle(color: selectedItems.isEmpty ? const Color(0xFF6B7280) : const Color(0xFF111827), fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    if (selectedItems.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        selectedItems.map((e) => e.name).join(', '),
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_drop_down_rounded, color: const Color(0xFF10B981), size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsAgreement(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: const Color(0xFF10B981)),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280), height: 1.4),
                children: [
                  const TextSpan(text: 'By creating an account, you agree to our '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(RegisterCtrl ctrl, BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: ctrl.isLoading.value ? null : ctrl.register,
        style: ElevatedButton.styleFrom(
          backgroundColor: ctrl.isLoading.value ? const Color(0xFFE5E7EB) : const Color(0xFF10B981),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          disabledBackgroundColor: const Color(0xFFE5E7EB),
          shadowColor: Colors.transparent,
        ),
        child: ctrl.isLoading.value
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(decoration.colorScheme.onPrimary)))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt_1_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginRedirect(BuildContext context, RegisterCtrl ctrl) {
    return Row(
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
    );
  }

  Widget _buildBackButton() {
    return Container(
      height: 45,
      width: 45,
      margin: const EdgeInsets.all(20),
      child: IconButton(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
        ),
        onPressed: () => Get.close(1),
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        color: const Color(0xFF111827),
      ),
    );
  }

  void _showServicesSelection(BuildContext context, RegisterCtrl ctrl) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        child: MultiSelectBottomSheet(title: 'Select Services', selectedItems: ctrl.selectedServices, onSelectionChanged: ctrl.updateSelectedServices, itemType: 'services'),
      ),
    );
  }

  void _showEquipmentSelection(BuildContext context, RegisterCtrl ctrl) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          child: MultiSelectBottomSheet(title: 'Select Equipment', selectedItems: ctrl.selectedEquipment, onSelectionChanged: ctrl.updateSelectedEquipment, itemType: 'equipment'),
        );
      },
    );
  }
}
