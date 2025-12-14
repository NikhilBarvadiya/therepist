import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/utils/network/api_config.dart';
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
          body: RefreshIndicator(
            onRefresh: () => ctrl.refreshServices(),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  toolbarHeight: 65,
                  backgroundColor: decoration.colorScheme.primary,
                  pinned: true,
                  floating: true,
                  automaticallyImplyLeading: false,
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Equipment', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                      Obx(() => Text('${ctrl.filteredEquipment.length} equipment available', style: GoogleFonts.poppins(fontSize: 14, letterSpacing: .5))),
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
                        icon: Icon(Icons.refresh, color: decoration.colorScheme.primary, size: 22),
                        onPressed: () => ctrl.refreshServices(),
                        tooltip: 'Refresh Equipment',
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
                      ),
                      child: TextField(
                        controller: searchController,
                        style: GoogleFonts.poppins(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Search equipment by name...',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 15),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500], size: 22),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear_rounded, color: Colors.grey[500], size: 20),
                                  onPressed: () {
                                    searchController.clear();
                                    ctrl.searchServices('');
                                  },
                                )
                              : const SizedBox.shrink(),
                        ),
                        onChanged: (value) => ctrl.searchServices(value),
                      ),
                    ),
                  ),
                ),
                Obx(() {
                  if (ctrl.isLoading.value && ctrl.filteredEquipment.isEmpty) {
                    return _buildEquipmentShimmer();
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
                        final equipment = ctrl.filteredEquipment[index];
                        return _buildEquipmentCard(context, equipment, ctrl);
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

  Widget _buildEquipmentShimmer() {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 150,
                                height: 16,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 100,
                                height: 20,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 70,
                          height: 24,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }, childCount: 6),
      ),
    );
  }

  void _showImagesDialog(BuildContext context, ServiceModel equipment) {
    if (equipment.images.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            height: 400,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              equipment.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                            Text(
                              "Treatment in action",
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close, size: 22), onPressed: () => Get.close(1)),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    itemCount: equipment.images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            APIConfig.resourceBaseURL + equipment.images[index],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                    const SizedBox(height: 8),
                                    Text('Image not available', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (equipment.images.length > 1)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        equipment.images.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: index == 0 ? Colors.blue : Colors.grey[300]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEquipmentCard(BuildContext context, ServiceModel equipment, EquipmentCtrl ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: .3),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showImagesDialog(context, equipment),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: _getEquipmentColor(equipment.name).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: Icon(_getEquipmentIcon(equipment.name), color: _getEquipmentColor(equipment.name), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            equipment.name,
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            spacing: 10.0,
                            children: [
                              _buildEquipmentSpecs(equipment),
                              if (equipment.images.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.photo_library, size: 12, color: Colors.blueGrey),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${equipment.images.length}',
                                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(equipment.isActive),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(
                            equipment.description ?? 'Professional equipment for therapeutic use.',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: equipment.isActive,
                          activeColor: decoration.colorScheme.primary,
                          inactiveTrackColor: Colors.grey[400],
                          onChanged: (value) => ctrl.toggleServiceStatus(equipment.id, value),
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

  Widget _buildEquipmentSpecs(ServiceModel equipment) {
    final charge = equipment.charge ?? 0;
    final lowCharge = equipment.lowCharge ?? 0;
    final highCharge = equipment.highCharge ?? 0;
    String rateText;
    if (charge > 0) {
      rateText = '₹$charge/day';
    } else if (lowCharge > 0 && highCharge > 0) {
      rateText = '₹$lowCharge - ₹$highCharge/day';
    } else {
      rateText = 'Contact for rental';
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

  Widget _buildEmptyState(EquipmentCtrl ctrl) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.fitness_center_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 20),
        Text(
          'No Equipment Found',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            ctrl.searchQuery.value.isEmpty ? 'No equipment available for rental at the moment. Check back later.' : 'No equipment found for "${ctrl.searchQuery.value}". Try different keywords.',
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

  Color _getEquipmentColor(String equipmentName) {
    final name = equipmentName.toLowerCase();
    if (name.contains('treadmill') || name.contains('walker')) {
      return Colors.blue;
    } else if (name.contains('therapist') || name.contains('massage')) {
      return Colors.green;
    } else if (name.contains('wheelchair') || name.contains('crutch')) {
      return Colors.orange;
    } else if (name.contains('exercise') || name.contains('therapy')) {
      return Colors.purple;
    } else {
      return decoration.colorScheme.primary;
    }
  }

  IconData _getEquipmentIcon(String equipmentName) {
    final name = equipmentName.toLowerCase();
    if (name.contains('treadmill') || name.contains('exercise')) {
      return Icons.directions_run;
    } else if (name.contains('wheelchair')) {
      return Icons.accessible;
    } else if (name.contains('crutch') || name.contains('walker')) {
      return Icons.assist_walker;
    } else if (name.contains('massage')) {
      return Icons.spa;
    } else if (name.contains('therapist')) {
      return Icons.medical_services;
    } else {
      return Icons.fitness_center;
    }
  }
}
