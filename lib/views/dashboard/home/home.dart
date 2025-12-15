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
import 'package:therepist/views/dashboard/home/recognition/recognition.dart';
import 'package:therepist/views/dashboard/home/recognition/ui/recognition_card.dart';
import 'package:therepist/views/dashboard/home/recognition/ui/recognition_shimmer.dart';
import 'package:therepist/views/dashboard/profile/settings.dart';
import 'package:therepist/views/dashboard/recharge/recharge.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeCtrl>(
      init: HomeCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: RefreshIndicator(
            onRefresh: () => ctrl.loadHomeData(),
            color: decoration.colorScheme.primary,
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    _buildModernAppBar(ctrl),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    _buildEnhancedBannerSection(ctrl),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    _buildQuickStatsCards(ctrl),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    _buildRecognitionsSection(ctrl),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    _buildPendingRequestsSection(ctrl),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    _buildTodayAppointmentsSection(ctrl),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
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
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(width: 70, height: 70, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(decoration.colorScheme.primary), strokeWidth: 4)),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(icon, size: 28, color: decoration.colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('Please wait...', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar(HomeCtrl ctrl) {
    return SliverAppBar(
      elevation: 0,
      toolbarHeight: 70,
      pinned: true,
      floating: false,
      expandedHeight: 130,
      centerTitle: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.85)]),
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16, right: 24),
        title: Obx(
          () => ctrl.isLoading.value
              ? _buildAppBarShimmer()
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back 👋',
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${ctrl.userName.value.capitalizeFirst}",
                            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: IconButton(
            icon: const Icon(Icons.wallet, color: Colors.white, size: 22),
            onPressed: () => Get.to(() => const Recharge()),
            tooltip: 'Rewards',
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
            onPressed: () => Get.to(() => const Settings()),
            tooltip: 'Settings',
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedBannerSection(HomeCtrl ctrl) {
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
        return Container(
          height: 160,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: PageView.builder(
            itemCount: banners.length,
            padEnds: false,
            controller: PageController(viewportFraction: 1),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.1),
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
                            child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: banner['color'] as Color,
                            child: const Icon(Icons.error, color: Colors.white, size: 40),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.7), Colors.black.withOpacity(0.3), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 24,
                          left: 24,
                          right: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                banner['title'].toString(),
                                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                banner['subtitle'].toString(),
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w400),
                              ),
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

  Widget _buildQuickStatsCards(HomeCtrl ctrl) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return _buildStatsShimmer();
          }
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.pending_actions_rounded,
                  label: 'Pending',
                  value: '${ctrl.pendingRequestsCount.value}',
                  color: Colors.orange,
                  gradient: [Colors.orange.shade400, Colors.orange.shade600],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.event_available_rounded,
                  label: 'Today',
                  value: '${ctrl.todayAppointmentsCount.value}',
                  color: Colors.blue,
                  gradient: [Colors.blue.shade400, Colors.blue.shade600],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color color, required List<Color> gradient}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                value,
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRecognitionsSection(HomeCtrl ctrl) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              spacing: 12.0,
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(color: decoration.colorScheme.primary, borderRadius: BorderRadius.circular(2)),
                ),
                Expanded(
                  child: Text(
                    'Recent Recognitions',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B), letterSpacing: 0.5),
                  ),
                ),
                TextButton(
                  onPressed: () => Get.to(() => const RecognitionScreen(), transition: Transition.rightToLeft),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: decoration.colorScheme.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('View All', style: GoogleFonts.inter(color: decoration.colorScheme.primary, letterSpacing: .5, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (ctrl.isLoadingHome.value) {
              return const HomeRecognitionShimmer();
            }
            return ctrl.homeRecognitions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildEmptyState(icon: Icons.card_giftcard_rounded, title: 'No Recognitions', subtitle: 'Your recognitions will appear here', color: Colors.purple),
                  )
                : SizedBox(
                    height: 250,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: ctrl.homeRecognitions.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final recognition = ctrl.homeRecognitions[index];
                        return SizedBox(width: 200, child: RecognitionCard(recognition: recognition, isCompact: true));
                      },
                    ),
                  );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPendingRequestsSection(HomeCtrl ctrl) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(color: decoration.colorScheme.primary, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pending Requests',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B), letterSpacing: 0.5),
                  ),
                ),
                Obx(
                  () => ctrl.isLoading.value
                      ? _buildCountShimmer()
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            '${ctrl.pendingRequestsCount.value}',
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.orange.shade700, fontWeight: FontWeight.w700),
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (ctrl.isLoading.value) {
              return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _buildPendingRequestsShimmer());
            }
            return ctrl.pendingAppointments.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildEmptyState(icon: Icons.check_circle_outline_rounded, title: 'All Caught Up!', subtitle: 'No pending requests at the moment', color: Colors.green),
                  )
                : SizedBox(
                    height: 250,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: ctrl.pendingAppointments.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final request = ctrl.pendingAppointments[index];
                        return _buildPendingRequestCard(request, ctrl).paddingOnly(bottom: 10);
                      },
                    ),
                  );
          }),
        ],
      ),
    );
  }

  Widget _buildTodayAppointmentsSection(HomeCtrl ctrl) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(color: decoration.colorScheme.primary, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Today\'s Appointments',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B), letterSpacing: 0.5),
                  ),
                ),
                TextButton(
                  onPressed: () => Get.to(() => const Appointments(), transition: Transition.rightToLeft),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: decoration.colorScheme.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('View All', style: GoogleFonts.inter(color: decoration.colorScheme.primary, letterSpacing: .5, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (ctrl.isLoading.value) {
              return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _buildTodayAppointmentsShimmer());
            }
            return ctrl.todayAppointments.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildEmptyState(icon: Icons.calendar_today_rounded, title: 'No Appointments Today', subtitle: 'Enjoy your free time!', color: Colors.blue),
                  )
                : SizedBox(
                    height: 180,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: ctrl.todayAppointments.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final appointment = ctrl.todayAppointments[index];
                        return _buildAppointmentCard(appointment).paddingOnly(bottom: 10);
                      },
                    ),
                  );
          }),
        ],
      ),
    );
  }

  Widget _buildPendingRequestCard(AppointmentModel request, HomeCtrl ctrl) {
    final formattedDate = DateFormat('dd MMM yyyy').format(request.requestedAt);
    final formattedTime = DateFormat('hh:mm a').format(request.requestedAt);

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          request.patientName.capitalizeFirst.toString(),
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          request.patientAddress,
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => helper.makePhoneCall(request.patientMobile),
                    icon: Icon(Icons.phone_rounded, color: AppTheme.primaryLight, size: 18),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(14)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.medical_services_rounded, request.serviceName),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.calendar_today_rounded, formattedDate),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildInfoRow(Icons.access_time_rounded, formattedTime)),
                      const SizedBox(width: 8),
                      _buildInfoRow(Icons.currency_rupee_rounded, '${request.charge}'),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => ctrl.acceptRequest(request.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: decoration.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text('Accept Request', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
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
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        appointment.patientName.capitalizeFirst.toString(),
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appointment.patientAddress,
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.medical_services_rounded, appointment.serviceName),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildInfoRow(Icons.calendar_today_rounded, formattedDate)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildInfoRow(Icons.access_time_rounded, formattedTime)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 40, color: color),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.3),
      highlightColor: Colors.white.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 13,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 6),
          Container(
            width: 180,
            height: 20,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerShimmer() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildStatsShimmer() {
    return Row(
      children: [
        Expanded(child: _buildStatCardShimmer()),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCardShimmer()),
      ],
    );
  }

  Widget _buildStatCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        height: 120,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget _buildPendingRequestsShimmer() {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Container(
              width: 300,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayAppointmentsShimmer() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Container(
              width: 300,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'completed':
        return const Color(0xFF3B82F6);
      default:
        return Colors.grey;
    }
  }
}
