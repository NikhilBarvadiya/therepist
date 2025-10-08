import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/views/dashboard/equipment/equipment_ctrl.dart';
import '../../../models/service_model.dart';

class Equipment extends StatelessWidget {
  Equipment({super.key});

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EquipmentCtrl>(
      init: EquipmentCtrl(),
      builder: (ctrl) {
        scrollController.addListener(() {
          if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
            ctrl.loadMoreServices();
          }
        });
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: RefreshIndicator(
            onRefresh: () => ctrl.refreshServices(),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  elevation: 0,
                  toolbarHeight: 65,
                  backgroundColor: Colors.white,
                  pinned: true,
                  floating: true,
                  automaticallyImplyLeading: false,
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Equipment',
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Obx(() => Text('${ctrl.filteredEquipment.length} equipment available', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]))),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                          backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
                        ),
                        icon: const Icon(Icons.refresh, color: Colors.black87, size: 22),
                        onPressed: () => ctrl.refreshServices(),
                        tooltip: 'Refresh Equipment',
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
                                    ctrl.clearSearch();
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) => ctrl.searchServices(value),
                      ),
                    ),
                  ),
                ),
                Obx(() {
                  if (ctrl.isLoading.value && ctrl.filteredEquipment.isEmpty) {
                    return SliverFillRemaining(child: _buildLoadingState());
                  }
                  if (ctrl.filteredEquipment.isEmpty && !ctrl.isLoading.value) {
                    return SliverFillRemaining(child: _buildEmptyState(ctrl));
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == ctrl.filteredEquipment.length) {
                          return _buildLoadMoreIndicator(ctrl);
                        }
                        final service = ctrl.filteredEquipment[index];
                        return _buildEquipmentCard(context, service, ctrl);
                      }, childCount: ctrl.filteredEquipment.length + (ctrl.hasMore.value ? 1 : 0)),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEquipmentCard(BuildContext context, ServiceModel service, EquipmentCtrl ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: Icon(service.icon ?? Icons.miscellaneous_services, color: decoration.colorScheme.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _buildRateDisplay(service),
                      ],
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
                        service.description ?? 'Professional service with customized treatment plans.',
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
    );
  }

  Widget _buildRateDisplay(ServiceModel service) {
    final charge = service.charge ?? 0;
    final lowCharge = service.lowCharge ?? 0;
    final highCharge = service.highCharge ?? 0;
    String rateText;
    if (charge > 0) {
      rateText = '₹$charge/session';
    } else if (lowCharge > 0 && highCharge > 0) {
      rateText = '₹$lowCharge - ₹$highCharge';
    } else {
      rateText = 'Contact for pricing';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(
        rateText,
        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blue[700]),
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

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Color(0xFF6C63FF)),
        const SizedBox(height: 20),
        Text(
          'Loading Services...',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildEmptyState(EquipmentCtrl ctrl) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.medical_services_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 20),
        Text(
          'No Equipment Found',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            ctrl.searchQuery.value.isEmpty ? 'No equipment available at the moment. Check back later.' : 'No equipment found for "${ctrl.searchQuery.value}". Try different keywords.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        if (ctrl.searchQuery.value.isNotEmpty)
          ElevatedButton(
            onPressed: () {
              searchController.clear();
              ctrl.clearSearch();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
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

  Widget _buildLoadMoreIndicator(EquipmentCtrl ctrl) {
    return Obx(() {
      if (ctrl.isLoadMoreLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))),
        );
      }
      return const SizedBox();
    });
  }
}
