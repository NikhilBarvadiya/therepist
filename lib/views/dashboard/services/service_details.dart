import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:therepist/models/models.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/views/dashboard/services/services_ctrl.dart';

class ServiceDetails extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetails({super.key, required this.service});

  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ServicesCtrl>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            toolbarHeight: 65,
            backgroundColor: Colors.white,
            pinned: true,
            title: Text(
              widget.service.name,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServiceHeaderCard(widget.service),
                  const SizedBox(height: 24),
                  _buildDetailsSection(widget.service),
                  const SizedBox(height: 24),
                  _buildAdminControlsSection(ctrl),
                  const SizedBox(height: 24),
                  _buildActionButtons(ctrl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHeaderCard(ServiceModel service) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: Icon(service.icon, color: decoration.colorScheme.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Obx(() {
                  final ctrl = Get.find<ServicesCtrl>();
                  final currentService = ctrl.services.firstWhere((s) => s.id == service.id);
                  return _buildStatusBadge(currentService.isActive);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: isActive ? Colors.green : Colors.orange, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: isActive ? Colors.green : Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(ServiceModel service) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Details',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _buildDetailItem(icon: Icons.description_outlined, label: 'Description', value: service.description),
          const SizedBox(height: 12),
          _buildDetailItem(icon: Icons.category_outlined, label: 'Category', value: 'Physiotherapy'),
          const SizedBox(height: 12),
          _buildDetailItem(icon: Icons.palette_outlined, label: 'Service Color', value: 'Custom Theme', color: decoration.colorScheme.primary),
        ],
      ),
    );
  }

  Widget _buildDetailItem({required IconData icon, required String label, required String value, Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              if (color != null)
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      value,
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  ],
                )
              else
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminControlsSection(ServicesCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Management',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final currentService = ctrl.services.firstWhere((s) => s.id == widget.service.id);
            return _buildToggleSection(currentService, ctrl);
          }),
        ],
      ),
    );
  }

  Widget _buildToggleSection(ServiceModel currentService, ServicesCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: currentService.isActive ? Colors.green.withOpacity(0.05) : Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: currentService.isActive ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentService.isActive ? 'Service Active' : 'Service Inactive',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: currentService.isActive ? Colors.green : Colors.orange),
                ),
                const SizedBox(height: 4),
                Text(
                  currentService.isActive ? 'This service is currently visible to patients and accepting appointments.' : 'This service is hidden from patients and not accepting appointments.',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: currentService.isActive,
              activeColor: decoration.colorScheme.primary,
              inactiveTrackColor: Colors.grey[400],
              onChanged: (value) {
                currentService.isActive = value;
                ctrl.toggleServiceStatus(currentService.id, value);
                setState(() {});
                Get.snackbar(
                  value ? 'Service Enabled' : 'Service Disabled',
                  value ? '${currentService.name} is now active and visible to patients' : '${currentService.name} is now inactive and hidden from patients',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: value ? Colors.green : Colors.orange,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(15),
                  borderRadius: 12,
                  duration: const Duration(seconds: 3),
                );
                ctrl.update();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ServicesCtrl ctrl) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: Text(
              'Back to Services',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
          ),
        ),
      ],
    );
  }
}
