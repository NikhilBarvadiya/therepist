import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/views/dashboard/equipment/equipment.dart';
import 'package:therepist/views/dashboard/home/home.dart';
import 'package:therepist/views/dashboard/profile/profile.dart';
import 'package:therepist/views/dashboard/services/services.dart';
import 'dashboard_ctrl.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardCtrl>(
      init: DashboardCtrl(),
      builder: (ctrl) {
        return PopScope(
          canPop: false,
          child: Obx(
            () => Scaffold(
              body: IndexedStack(index: ctrl.currentIndex.value, children: [Home(), Services(), Equipment(), Profile()]),
              bottomNavigationBar: _buildBottomNavBar(ctrl),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar(DashboardCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, -8))],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0, isActive: ctrl.currentIndex.value == 0, onTap: () => ctrl.changeTab(0)),
              _buildNavItem(icon: Icons.medical_services_rounded, label: 'Services', index: 1, isActive: ctrl.currentIndex.value == 1, onTap: () => ctrl.changeTab(1)),
              _buildNavItem(icon: Icons.inventory_2_rounded, label: 'Equipment', index: 2, isActive: ctrl.currentIndex.value == 2, onTap: () => ctrl.changeTab(2)),
              _buildNavItem(icon: Icons.person_rounded, label: 'Profile', index: 3, isActive: ctrl.currentIndex.value == 3, onTap: () => ctrl.changeTab(3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index, required bool isActive, required VoidCallback onTap}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: decoration.colorScheme.primary.withOpacity(0.1),
          highlightColor: decoration.colorScheme.primary.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Icon(icon, color: isActive ? decoration.colorScheme.primary : Colors.grey[500], size: isActive ? 26 : 24),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? decoration.colorScheme.primary : Colors.grey[600],
                    letterSpacing: 0.1,
                  ),
                  child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
