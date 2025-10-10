import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:therepist/models/appointment_model.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/utils/helper.dart';
import 'package:therepist/utils/theme/light.dart';
import 'package:therepist/views/dashboard/home/home_ctrl.dart';
import 'package:therepist/views/dashboard/home/appointments/appointments.dart';
import 'package:therepist/views/dashboard/profile/settings.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeCtrl>(
      init: HomeCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: RefreshIndicator(
            onRefresh: () => ctrl.loadHomeData(),
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    _buildAppBar(ctrl),
                    _buildBannerSection(ctrl),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    _buildPendingRequestsSection(ctrl),
                    _buildTodayAppointmentsSection(ctrl),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
                Obx(() {
                  if (ctrl.isAcceptLoading.value) {
                    return _buildFullScreenLoading('Accepting Request...', Icons.check_circle_outline);
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFullScreenLoading(String message, IconData icon) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(decoration.colorScheme.primary), strokeWidth: 3),
                  ),
                  Icon(icon, size: 30, color: decoration.colorScheme.primary),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('Please wait...', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(HomeCtrl ctrl) {
    return SliverAppBar(
      elevation: 0,
      toolbarHeight: 80,
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
          () => ctrl.isLoading.value
              ? _buildAppBarShimmer()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello,', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                    Text(
                      "Dr. ${ctrl.userName.value.capitalizeFirst.toString()}",
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
        ),
      ),
      actions: [
        IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
          ),
          icon: Icon(Icons.settings_outlined, color: decoration.colorScheme.primary, size: 20),
          onPressed: () => Get.to(() => const Settings()),
          tooltip: 'Settings',
        ).paddingOnly(right: 8.0),
      ],
    );
  }

  Widget _buildBannerSection(HomeCtrl ctrl) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (ctrl.isLoading.value) {
          return _buildBannerShimmer();
        }
        final banners = [
          {
            'image': 'https://images.pexels.com/photos/3825529/pexels-photo-3825529.jpeg',
            'title': 'Welcome to Our Clinic',
            'subtitle': 'Where care meets expertise — your recovery starts here.',
            'color': Colors.blue[700]!,
          },
          {
            'image': 'https://images.pexels.com/photos/4506107/pexels-photo-4506107.jpeg',
            'title': 'Special Offer',
            'subtitle': 'Enjoy 20% off your first physiotherapy session!',
            'color': Colors.green[700]!,
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
                              Text(banner['subtitle'].toString(), style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.9))),
                            ],
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
      }),
    );
  }

  Widget _buildPendingRequestsSection(HomeCtrl ctrl) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pending Requests',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                Obx(
                  () => ctrl.isLoading.value
                      ? _buildCountShimmer()
                      : Text(
                          '${ctrl.pendingRequestsCount.value}',
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (ctrl.isLoading.value) {
                return _buildPendingRequestsShimmer();
              }
              return ctrl.pendingAppointments.isEmpty
                  ? _buildEmptyState(icon: Icons.pending_actions_outlined, title: 'No Pending Requests', subtitle: 'You\'re all caught up!')
                  : SizedBox(
                      height: 210,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: ctrl.pendingAppointments.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final request = ctrl.pendingAppointments[index];
                          return _buildPendingRequestCard(request, ctrl);
                        },
                      ),
                    );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayAppointmentsSection(HomeCtrl ctrl) {
    return SliverToBoxAdapter(
      child: Padding(
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
                    () => ctrl.isLoading.value
                        ? _buildCountShimmer()
                        : Text(
                            'View All (${ctrl.todayAppointmentsCount.value})',
                            style: GoogleFonts.poppins(color: decoration.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (ctrl.isLoading.value) {
                return _buildTodayAppointmentsShimmer();
              }
              return ctrl.todayAppointments.isEmpty
                  ? _buildEmptyState(icon: Icons.calendar_today_outlined, title: 'No Appointments', subtitle: 'No appointments scheduled for today')
                  : SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: ctrl.todayAppointments.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final appointment = ctrl.todayAppointments[index];
                          return _buildAppointmentCard(appointment);
                        },
                      ),
                    );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 14,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 8),
          Container(
            width: 150,
            height: 20,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerShimmer() {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: 2,
        padEnds: false,
        controller: PageController(viewportFraction: 0.85),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade50,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingRequestsShimmer() {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Container(
              width: 280,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayAppointmentsShimmer() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Container(
              width: 280,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 120,
                                height: 16,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 80,
                                height: 12,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 150,
                              height: 12,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                            ),
                          ],
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

  Widget _buildCountShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        width: 40,
        height: 16,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  Widget _buildPendingRequestCard(AppointmentModel request, HomeCtrl ctrl) {
    final formattedDate = DateFormat('dd MMM yyyy').format(request.requestedAt);
    final formattedTime = DateFormat('hh:mm a').format(request.requestedAt);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: .3),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.patientName.capitalizeFirst.toString(),
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(request.patientAddress, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => helper.makePhoneCall(request.patientMobile),
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                    padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                    backgroundColor: WidgetStatePropertyAll(AppTheme.primaryLight.withOpacity(0.1)),
                  ),
                  icon: Icon(Icons.phone_rounded, color: AppTheme.primaryLight, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.medical_services_outlined, request.serviceName),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.calendar_today_outlined, '$formattedDate at $formattedTime'),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.attach_money_rounded, '₹${request.charge}'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => ctrl.acceptRequest(request.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: decoration.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text('Accept', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    final statusColor = _getStatusColor(appointment.status);
    final formattedDate = DateFormat('dd MMM yyyy').format(appointment.requestedAt);
    final formattedTime = DateFormat('hh:mm a').format(appointment.requestedAt);
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: .3),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName.capitalizeFirst.toString(),
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(appointment.patientAddress, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.medical_services_outlined, appointment.serviceName),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.calendar_today_outlined, formattedDate),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: _buildInfoRow(Icons.access_time_outlined, formattedTime)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
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
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
      case 'accepted':
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
}
