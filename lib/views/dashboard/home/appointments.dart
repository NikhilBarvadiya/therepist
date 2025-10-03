import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:therepist/models/models.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/views/dashboard/dashboard_ctrl.dart';

class Appointments extends StatelessWidget {
  const Appointments({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DashboardCtrl>();
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            toolbarHeight: 65,
            backgroundColor: Colors.white,
            pinned: true,
            floating: true,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appointments',
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Obx(() => Text('${ctrl.filteredAppointments.length} total appointments', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]))),
              ],
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
              onPressed: () => Get.back(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search appointments...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () {
                              searchController.clear();
                              ctrl.searchAppointments('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    ctrl.searchAppointments(value);
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(
              () => SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFilterChip('All', ctrl.selectedStatus.value == '', ctrl),
                    _buildFilterChip('Confirmed', ctrl.selectedStatus.value == 'confirmed', ctrl),
                    _buildFilterChip('Pending', ctrl.selectedStatus.value == 'pending', ctrl),
                    _buildFilterChip('Cancelled', ctrl.selectedStatus.value == 'cancelled', ctrl),
                    _buildFilterChip('Completed', ctrl.selectedStatus.value == 'completed', ctrl),
                  ],
                ),
              ),
            ),
          ),
          Obx(
            () => ctrl.filteredAppointments.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final appointment = ctrl.filteredAppointments[index];
                      return Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: _buildAppointmentCard(appointment));
                    }, childCount: ctrl.filteredAppointments.length),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, DashboardCtrl ctrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.grey[700]),
        ),
        selected: isSelected,
        onSelected: (selected) {
          ctrl.filterAppointmentsByStatus(selected ? label.toLowerCase() : '');
        },
        backgroundColor: Colors.white,
        selectedColor: decoration.colorScheme.primary,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? decoration.colorScheme.primary : Colors.grey[300]!),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    Color statusColor = _getStatusColor(appointment.status);
    IconData statusIcon = _getStatusIcon(appointment.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: decoration.colorScheme.primary.withOpacity(0.1),
                        radius: 24,
                        child: Icon(Icons.person, color: decoration.colorScheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          appointment.patientName,
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        appointment.status.toUpperCase(),
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildDetailItem(Icons.calendar_today_outlined, 'Date', appointment.date)),
                      Expanded(child: _buildDetailItem(Icons.access_time_outlined, 'Time', appointment.time)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(children: [Expanded(child: _buildDetailItem(Icons.medical_services_outlined, 'Service', appointment.service))]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[500]),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 20),
        Text(
          'No Appointments Found',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Text(
          'Try adjusting your search or filter criteria',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            final ctrl = Get.find<DashboardCtrl>();
            ctrl.searchAppointments('');
            ctrl.filterAppointmentsByStatus('');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: decoration.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Clear Filters',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.pending_outlined;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'completed':
        return Icons.verified_outlined;
      default:
        return Icons.calendar_today_outlined;
    }
  }
}
