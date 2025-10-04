import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:therepist/models/models.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/views/dashboard/services/service_details.dart';
import 'package:therepist/views/dashboard/services/services_ctrl.dart';

class Services extends StatelessWidget {
  const Services({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    return GetBuilder<ServicesCtrl>(
      init: ServicesCtrl(),
      builder: (ctrl) {
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
                      'Services',
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Obx(() => Text('${ctrl.filteredServices.length} services available', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]))),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.refresh, color: Colors.black87, size: 22),
                      ),
                      onPressed: () => ctrl.filterServices(),
                      tooltip: 'Refresh Services',
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search services...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey[600]),
                                onPressed: () {
                                  searchController.clear();
                                  ctrl.searchServices('');
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) => ctrl.searchServices(value),
                    ),
                  ),
                ),
              ),
              Obx(
                () => ctrl.filteredServices.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState())
                    : SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final service = ctrl.filteredServices[index];
                            return _buildServiceCard(context, service, ctrl);
                          }, childCount: ctrl.filteredServices.length),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceModel service, ServicesCtrl ctrl) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => ServiceDetails(service: service)),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 12.0,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: Icon(service.icon, color: decoration.colorScheme.primary, size: 24),
                    ),
                    Expanded(
                      child: Text(
                        service.name,
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusBadge(service.isActive),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.description,
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ).paddingOnly(left: 12),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: service.isActive,
                          activeColor: decoration.colorScheme.primary,
                          inactiveTrackColor: Colors.grey[400],
                          onChanged: (value) => ctrl.toggleServiceStatus(service.id, value),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: isActive ? Colors.green : Colors.orange, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: isActive ? Colors.green : Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.medical_services_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 20),
        Text(
          'No Services Found',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Try adjusting your search criteria or check back later for new services',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            final ctrl = Get.find<ServicesCtrl>();
            ctrl.searchServices('');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF6C63FF),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Clear Search',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
