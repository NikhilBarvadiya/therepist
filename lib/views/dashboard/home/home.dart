import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:therepist/models/models.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/views/dashboard/dashboard_ctrl.dart';
import 'package:therepist/views/dashboard/home/appointments.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DashboardCtrl>();

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
            expandedHeight: 120,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(color: Colors.white),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Obx(
                () => Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello,', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                    Text(
                      ctrl.userName.value,
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Badge(
                    smallSize: 8,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.notifications_outlined, color: Colors.black87),
                  ),
                  onPressed: () => Get.snackbar('Notifications', 'No new notifications', snackPosition: SnackPosition.BOTTOM),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildBannerSection(),
                const SizedBox(height: 32),
                _buildPendingRequestsSection(ctrl),
                const SizedBox(height: 20),
                _buildAppointmentsSection(ctrl),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    final banners = [
      {
        'image': 'https://images.pexels.com/photos/3825529/pexels-photo-3825529.jpeg?auto=compress&cs=tinysrgb&w=1080',
        'title': 'Welcome to Our Clinic',
        'subtitle': 'Where care meets expertise — your recovery starts here.',
        'color': Colors.blue[700]!,
      },
      {
        'image': 'https://images.pexels.com/photos/4506107/pexels-photo-4506107.jpeg?auto=compress&cs=tinysrgb&w=1080',
        'title': 'Special Offer',
        'subtitle': 'Enjoy 20% off your first physiotherapy session!',
        'color': Colors.green[700]!,
      },
      {
        'image': 'https://images.pexels.com/photos/8376234/pexels-photo-8376234.jpeg?auto=compress&cs=tinysrgb&w=1080',
        'title': 'New Services',
        'subtitle': 'Now offering maternity & pediatric physiotherapy programs.',
        'color': Colors.purple[700]!,
      },
    ];

    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: banners.length,
        padEnds: false,
        controller: PageController(viewportFraction: 0.85),
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: banner['image'].toString(),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: banner['color'] as Color,
                        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: banner['color'] as Color,
                        child: const Icon(Icons.error, color: Colors.white, size: 40),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.black.withOpacity(0.6), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner['title'].toString(),
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(banner['subtitle'].toString(), style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          banners.length,
                          (i) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: i == index ? Colors.white : Colors.white.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingRequestsSection(DashboardCtrl ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Patients Requests',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              Obx(
                () => Text(
                  '${ctrl.filteredPendingRequests.length}',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => ctrl.filteredPendingRequests.isEmpty
                ? _buildEmptyState(icon: Icons.pending_actions_outlined, title: 'No Pending Requests', subtitle: 'You\'re all caught up!')
                : SizedBox(
                    height: 175,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: ctrl.filteredPendingRequests.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final request = ctrl.filteredPendingRequests[index];
                        return _buildPendingRequestCard(request);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsSection(DashboardCtrl ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Today\'s Appointments',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              TextButton(
                onPressed: () => Get.to(() => const Appointments(), transition: Transition.rightToLeft),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                child: Obx(
                  () => Text(
                    'View All (${ctrl.filteredAppointments.length})',
                    style: GoogleFonts.poppins(color: decoration.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => ctrl.filteredAppointments.isEmpty
                ? _buildEmptyState(icon: Icons.calendar_today_outlined, title: 'No Appointments', subtitle: 'No appointments scheduled for today')
                : SizedBox(
                    height: 165,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: ctrl.filteredAppointments.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final appointment = ctrl.filteredAppointments[index];
                        return _buildAppointmentCard(appointment);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestCard(RequestModel request) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  child: Icon(Icons.person, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    request.patientName,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.medical_services_outlined, request.service),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today_outlined, request.date),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(
                'Pending',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.orange[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    Color statusColor = _getStatusColor(appointment.status);
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: decoration.colorScheme.primary.withOpacity(0.1),
                  child: Icon(Icons.person, color: decoration.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appointment.patientName,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildInfoRow(Icons.calendar_today_outlined, appointment.date), _buildInfoRow(Icons.access_time_outlined, appointment.time)],
            ),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.medical_services_outlined, appointment.service),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    appointment.status.capitalizeFirst.toString(),
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: statusColor),
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
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
      default:
        return Colors.grey;
    }
  }
}
