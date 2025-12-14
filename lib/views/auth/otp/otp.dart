import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:therepist/views/auth/otp/otp_ctrl.dart';

class Otp extends StatelessWidget {
  Otp({super.key, required this.email});

  final String email;
  final OtpCtrl ctrl = Get.put(OtpCtrl());

  @override
  Widget build(BuildContext context) {
    ctrl.email = email;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(children: [const SizedBox(height: 60), _buildLogo(context), const SizedBox(height: 40), _buildOtpForm(context), const SizedBox(height: 40), _buildResendOption(context)]),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Icon(Icons.verified_user_rounded, size: 50, color: Theme.of(context).colorScheme.onPrimary),
        ),
        const SizedBox(height: 24),
        Text('Verify Your Number', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 28)),
        const SizedBox(height: 8),
        Text(
          'We sent a code to $email',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text('Signing you in...', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7))),
      ],
    );
  }

  Widget _buildOtpForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ENTER VERIFICATION CODE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant, letterSpacing: 0.8),
        ),
        const SizedBox(height: 12),
        _buildOtpField(context),
        const SizedBox(height: 24),
        _buildTimer(context),
        const SizedBox(height: 32),
        _buildVerifyButton(context),
      ],
    );
  }

  Widget _buildOtpField(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: ctrl.otpController,
        keyboardType: TextInputType.number,
        maxLength: 4,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 8),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: '0000',
          hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3), letterSpacing: 8),
          border: InputBorder.none,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: ctrl.onOtpChanged,
      ),
    );
  }

  Widget _buildTimer(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(ctrl.canResend.value ? "Didn't receive the code? " : "Resend code in ", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          if (!ctrl.canResend.value)
            Text(
              '${ctrl.timerCount.value}s',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
            ),
          if (ctrl.canResend.value)
            GestureDetector(
              onTap: ctrl.resendOtp,
              child: Text(
                ' Resend OTP',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: ctrl.isLoading.value ? null : ctrl.verifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
          ),
          child: ctrl.isLoading.value
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'VERIFY OTP',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5, color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.verified, size: 20, color: Theme.of(context).colorScheme.onPrimary),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildResendOption(BuildContext context) {
    return Column(
      children: [
        Text(
          'Enter the 4-digit code sent to your phone',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Wrong number?',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
