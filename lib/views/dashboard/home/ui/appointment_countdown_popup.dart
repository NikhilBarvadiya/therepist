import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:therepist/models/appointment_model.dart';
import 'package:vibration/vibration.dart';

class AppointmentCountdownPopup extends StatefulWidget {
  final AppointmentModel appointment;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback? onTimeout;

  const AppointmentCountdownPopup({super.key, required this.appointment, required this.onAccept, required this.onReject, this.onTimeout});

  @override
  State<AppointmentCountdownPopup> createState() => _AppointmentCountdownPopupState();
}

class _AppointmentCountdownPopupState extends State<AppointmentCountdownPopup> with TickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _slideController;
  late AnimationController _countdownController;
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _countdownAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  int _countdown = 30;
  bool _isDisposed = false;
  AudioPlayer player = AudioPlayer();

  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _accentGreen = Color(0xFF00A651);
  static const Color _warningRed = Color(0xFFE23744);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startCountdown();
    _playAppointmentSound();
    _vibrate();
  }

  void _setupAnimations() {
    _slideController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _countdownController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _shakeController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    _countdownAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _countdownController, curve: Curves.easeOut));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut));
    _slideController.forward();
    _countdownController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdown--;
      });
      if (_countdown <= 10 && _countdown > 0) {
        _shakeController.reset();
        _shakeController.forward();
      }
      if (_countdown <= 0) {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  void _playAppointmentSound() async {
    await player.setSource(AssetSource('slow_spring_board.mp3'));
    await player.play(AssetSource('slow_spring_board.mp3'));
  }

  void _vibrate() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(pattern: [150, 200, 300, 200, 150]);
    }
  }

  void _handleTimeout() {
    if (_isDisposed) return;
    widget.onTimeout?.call();
    _closePopup();
  }

  void _handleAccept() {
    if (_isDisposed) return;
    widget.onAccept();
    _closePopup();
  }

  void _handleReject() {
    if (_isDisposed) return;
    widget.onReject();
    _closePopup();
  }

  void _closePopup() {
    if (_isDisposed) return;
    _slideController.reverse().then((_) {
      if (!_isDisposed && mounted) {
        Get.back();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer.cancel();
    _slideController.dispose();
    _countdownController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, spreadRadius: 0, offset: const Offset(0, 10))],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [_buildHeader(), _buildCountdownSection(), _buildAppointmentDetails(), _buildActionButtons()]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_primaryBlue, _accentGreen], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.medical_services, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Appointment Alert!',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Accept within ${_countdown}s',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(sin(_shakeAnimation.value * pi * 4) * 2, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '$_countdown',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _countdown > 15
                      ? [_accentGreen, const Color(0xFF00C851)]
                      : _countdown > 10
                      ? [_primaryBlue, const Color(0xFF3B82F6)]
                      : [_warningRed, const Color(0xFFFF4444)],
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        (_countdown > 15
                                ? _accentGreen
                                : _countdown > 10
                                ? _primaryBlue
                                : _warningRed)
                            .withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _countdownAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _countdownAnimation.value,
                      child: Text(
                        '$_countdown',
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildDetailRow(icon: Icons.person, title: 'Patient', subtitle: widget.appointment.patientName, color: _primaryBlue),
          const SizedBox(height: 12),
          _buildDetailRow(icon: Icons.location_on, title: 'Patient Address', subtitle: widget.appointment.patientAddress, color: _accentGreen, maxLines: 2),
          const SizedBox(height: 12),
          _buildDetailRow(icon: Icons.medical_services, title: 'Service', subtitle: '${widget.appointment.serviceName} (${widget.appointment.preferredType})', color: _primaryBlue),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: _accentGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.currency_rupee, color: _accentGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appointment Charge',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '₹${widget.appointment.charge}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _accentGreen),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String title, required String subtitle, required Color color, int maxLines = 1}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(onPressed: _handleReject, text: 'Reject', color: _warningRed, icon: Icons.close),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(onPressed: _handleAccept, text: 'Accept', color: _accentGreen, icon: Icons.check),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required VoidCallback onPressed, required String text, required Color color, required IconData icon}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
