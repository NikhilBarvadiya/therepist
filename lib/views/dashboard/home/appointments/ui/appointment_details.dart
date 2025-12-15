import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:therepist/models/appointment_model.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/utils/helper.dart';
import 'package:therepist/views/dashboard/home/appointments/appointments_ctrl.dart';

class AppointmentDetails extends StatefulWidget {
  final String appointmentId;
  final bool? fromHomeScreen;

  const AppointmentDetails({super.key, required this.appointmentId, this.fromHomeScreen = false});

  @override
  State<AppointmentDetails> createState() => _AppointmentDetailsState();
}

class _AppointmentDetailsState extends State<AppointmentDetails> {
  final AppointmentsCtrl ctrl = Get.find<AppointmentsCtrl>();
  AppointmentModel? _appointment;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  void _loadAppointment() {
    _appointment = ctrl.appointments.where((app) => app.id == widget.appointmentId).first;
  }

  @override
  Widget build(BuildContext context) {
    if (_appointment == null) {
      return _buildLoadingScreen();
    }
    final appointment = _appointment!;
    final formattedDate = DateFormat('EEE, dd MMM yyyy').format(appointment.requestedAt);
    final formattedTime = DateFormat('hh:mm a').format(appointment.requestedAt);
    final dayOfWeek = DateFormat('EEEE').format(appointment.requestedAt);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            toolbarHeight: 70,
            backgroundColor: decoration.colorScheme.primary,
            pinned: true,
            floating: true,
            leading: IconButton(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
                backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
              ),
              icon: Icon(Icons.arrow_back, color: decoration.colorScheme.primary),
              onPressed: () => Get.close(1),
            ),
            title: Text('Appointment Details', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildOverviewCard(appointment, formattedDate, formattedTime, dayOfWeek),
                const SizedBox(height: 24),
                _buildSectionTitle('Patient Information'),
                const SizedBox(height: 12),
                _buildPatientCard(appointment),
                const SizedBox(height: 20),
                _buildSectionTitle('Appointment Details'),
                const SizedBox(height: 12),
                _buildAppointmentDetailsCard(appointment, formattedDate, formattedTime),
                const SizedBox(height: 20),
                _buildStatusTimeline(appointment),
                const SizedBox(height: 20),
                if (appointment.status.toLowerCase() == 'pending' || appointment.status.toLowerCase() == 'accepted') _buildActionSection(appointment),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.close(1),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        title: Text(
          'Appointment Details',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(decoration.colorScheme.primary), strokeWidth: 3),
                  Center(child: Icon(Icons.calendar_month_rounded, color: decoration.colorScheme.primary, size: 24)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Loading appointment details...', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(AppointmentModel appointment, String formattedDate, String formattedTime, String dayOfWeek) {
    final statusColor = _getStatusColor(appointment.status);
    final statusIcon = _getStatusIcon(appointment.status);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.2), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 8),
                      Text(
                        appointment.status.toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD54F).withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.currency_rupee_rounded, size: 14, color: Color(0xFFF57C00)),
                      const SizedBox(width: 6),
                      Text(
                        '₹${appointment.charge}',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFF57C00)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: decoration.colorScheme.primary.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: decoration.colorScheme.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Text(
                    appointment.serviceName,
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87, height: 1.3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appointment.preferredType,
                    style: GoogleFonts.inter(fontSize: 15, color: decoration.colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(color: decoration.colorScheme.primary, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildPatientCard(AppointmentModel appointment) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: decoration.colorScheme.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName.capitalizeFirst.toString(),
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text('Patient', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDetailRow(Icons.phone_rounded, 'Phone Number', appointment.patientMobile, isAction: true, onTap: () => helper.makePhoneCall(appointment.patientMobile), showDivider: true),
                const SizedBox(height: 16),
                if (appointment.patientEmail.isNotEmpty)
                  Column(children: [_buildDetailRow(Icons.email_rounded, 'Email Address', appointment.patientEmail, showDivider: true), const SizedBox(height: 16)]),
                if (appointment.patientAddress.isNotEmpty) _buildDetailRow(Icons.location_on_rounded, 'Address', appointment.patientAddress),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetailsCard(AppointmentModel appointment, String formattedDate, String formattedTime) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildDetailRow(Icons.calendar_month_rounded, 'Appointment Date', formattedDate, showDivider: true),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.access_time_rounded, 'Appointment Time', formattedTime, showDivider: true),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.medical_services_rounded, 'Service Type', appointment.serviceName, showDivider: true),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.category_rounded, 'Consultation Type', appointment.preferredType),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(AppointmentModel appointment) {
    final List<Map<String, dynamic>> timelineSteps = [
      {'status': 'Requested', 'date': DateFormat('dd MMM, hh:mm a').format(appointment.createdAt), 'icon': Icons.schedule_rounded, 'color': Colors.blue, 'isActive': true},
      {
        'status': appointment.status,
        'date': DateFormat('dd MMM, hh:mm a').format(appointment.updatedAt),
        'icon': _getStatusIcon(appointment.status),
        'color': _getStatusColor(appointment.status),
        'isActive': appointment.status.toLowerCase() != 'pending',
      },
      {'status': 'Completed', 'date': 'Upcoming', 'icon': Icons.verified_rounded, 'color': Colors.green, 'isActive': appointment.status.toLowerCase() == 'completed'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Status Timeline'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Column(
            children: timelineSteps.asMap().entries.map((entry) {
              final int index = entry.key;
              final Map<String, dynamic> step = entry.value;
              final bool isLast = index == timelineSteps.length - 1;
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: step['isActive'] ? step['color'].withOpacity(0.1) : Colors.grey.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(color: step['isActive'] ? step['color'].withOpacity(0.3) : Colors.grey.shade300, width: 2),
                        ),
                        child: Icon(step['icon'], size: 20, color: step['isActive'] ? step['color'] : Colors.grey.shade400),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['status'].toString().toUpperCase(),
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: step['isActive'] ? step['color'] : Colors.grey.shade400),
                            ),
                            const SizedBox(height: 4),
                            Text(step['date'], style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.only(left: 19, top: 8, bottom: 8),
                      child: Container(width: 2, height: 30, color: Colors.grey.shade200),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isAction = false, bool showDivider = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: showDivider ? Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 20, color: decoration.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isAction) Icon(Icons.arrow_outward_rounded, size: 18, color: decoration.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionSection(AppointmentModel appointment) {
    final status = appointment.status.toLowerCase();
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => helper.makePhoneCall(appointment.patientMobile),
            icon: const Icon(Icons.phone_rounded, size: 18),
            label: Text('Call Patient', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: decoration.colorScheme.primary,
              side: BorderSide(color: decoration.colorScheme.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (status == 'pending')
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => ctrl.acceptAppointment(appointment.id),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text('Accept', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: decoration.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          )
        else if (status == 'accepted')
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(appointment.id, ctrl),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text('Cancel', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => ctrl.completeAppointment(appointment.id),
                  icon: const Icon(Icons.verified_rounded, size: 18),
                  label: Text('Complete', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _showCancelDialog(String appointmentId, AppointmentsCtrl ctrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.warning_rounded, color: Colors.red, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  'Cancel Appointment?',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'This action cannot be undone. The patient will be notified about the cancellation.',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.close(1),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Go Back', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ctrl.cancelAppointment(appointmentId);
                          Get.close(1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: Text('Yes, Cancel', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF059669);
      case 'pending':
        return const Color(0xFFD97706);
      case 'cancelled':
        return const Color(0xFFDC2626);
      case 'completed':
        return const Color(0xFF2563EB);
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.pending_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'completed':
        return Icons.verified_rounded;
      default:
        return Icons.calendar_month_rounded;
    }
  }
}
