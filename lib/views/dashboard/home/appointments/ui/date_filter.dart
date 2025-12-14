import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/views/dashboard/home/appointments/appointments_ctrl.dart';

class DateFilter extends StatefulWidget {
  const DateFilter({super.key});

  @override
  State<DateFilter> createState() => _DateFilterState();
}

class _DateFilterState extends State<DateFilter> {
  final ctrl = Get.find<AppointmentsCtrl>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      child: Container(
        height: size.height * 0.95,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        ),
        child: Column(children: [_buildHeader(), _buildContent(), _buildActions()]),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          IconButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
              backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
            ),
            icon: const Icon(Icons.close, color: Colors.black87, size: 22),
            onPressed: () => Get.close(1),
            tooltip: 'Refresh Services',
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Filter by Date',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
          ),
          Obx(() {
            if (ctrl.selectedDateRange.value == 'All Time') return const SizedBox();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(
                'Active',
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: decoration.colorScheme.primary),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QUICK SELECT',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 1),
            ),
            const SizedBox(height: 16),
            _buildQuickDateGrid(),
            Obx(() {
              if (ctrl.selectedDateRange.value == 'Custom Range') {
                return _buildCustomDateRange();
              }
              return _buildSelectedRangeCard();
            }),
            const SizedBox(height: 32),
            _buildCalendarSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3.5, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: ctrl.dateRanges.length,
      itemBuilder: (context, index) {
        return Obx(() {
          final range = ctrl.dateRanges[index];
          final isSelected = ctrl.selectedDateRange.value == range;
          final icon = _getRangeIcon(range);
          return GestureDetector(
            onTap: () {
              ctrl.selectedDateRange.value = range;
              if (range != 'Custom Range') {
                ctrl.customStartDate.value = null;
                ctrl.customEndDate.value = null;
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? decoration.colorScheme.primary.withOpacity(0.08) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? decoration.colorScheme.primary.withOpacity(0.3) : Colors.transparent, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: isSelected ? decoration.colorScheme.primary : Colors.grey.shade200, shape: BoxShape.circle),
                    child: Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey.shade600),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      range,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? decoration.colorScheme.primary : Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  IconData _getRangeIcon(String range) {
    switch (range) {
      case 'Today':
        return Icons.today_rounded;
      case 'Yesterday':
        return Icons.calendar_month;
      case 'Last 7 Days':
        return Icons.calendar_view_week_rounded;
      case 'Last 30 Days':
        return Icons.date_range_rounded;
      case 'This Month':
        return Icons.calendar_today_rounded;
      case 'Last Month':
        return Icons.arrow_back_ios_rounded;
      case 'Custom Range':
        return Icons.edit_calendar_rounded;
      default:
        return Icons.all_inclusive_rounded;
    }
  }

  Widget _buildCustomDateRange() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDatePicker(label: 'START DATE', date: ctrl.customStartDate.value, onTap: () => _pickDate(isStartDate: true)),
          const SizedBox(width: 10),
          _buildDatePicker(label: 'END DATE', date: ctrl.customEndDate.value, onTap: () => _pickDate(isStartDate: false)),
        ],
      ),
    );
  }

  Widget _buildDatePicker({required String label, required DateTime? date, required VoidCallback onTap}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                spacing: 10.0,
                children: [
                  Icon(Icons.calendar_month_rounded, size: 16, color: date != null ? decoration.colorScheme.primary : Colors.grey.shade400),
                  Expanded(
                    child: Stack(
                      children: [
                        if (date == null)
                          Text(
                            'Select date',
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey.shade500),
                          ),
                        if (date != null)
                          Text(
                            DateFormat('dd MMM').format(date),
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                      ],
                    ),
                  ),
                  if (date != null) Icon(Icons.close, size: 16, color: decoration.colorScheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedRangeCard() {
    if (ctrl.selectedDateRange.value == 'All Time') return const SizedBox();
    final rangeInfo = _getRangeInfo();
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [decoration.colorScheme.primary.withOpacity(0.05), decoration.colorScheme.primary.withOpacity(0.02)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: decoration.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.filter_alt_rounded, size: 22, color: decoration.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rangeInfo,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                Text(_getRangeSubtitle(), style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRangeInfo() {
    switch (ctrl.selectedDateRange.value) {
      case 'Today':
        return 'Today';
      case 'Yesterday':
        return 'Yesterday';
      case 'Last 7 Days':
        return 'Past 7 Days';
      case 'Last 30 Days':
        return 'Past 30 Days';
      case 'This Month':
        return 'This Month';
      case 'Last Month':
        return 'Last Month';
      default:
        return ctrl.selectedDateRange.value;
    }
  }

  String _getRangeSubtitle() {
    final now = DateTime.now();
    switch (ctrl.selectedDateRange.value) {
      case 'Today':
        return DateFormat('EEE, dd MMM yyyy').format(now);
      case 'Yesterday':
        return DateFormat('EEE, dd MMM yyyy').format(now.subtract(const Duration(days: 1)));
      case 'Last 7 Days':
        final start = now.subtract(const Duration(days: 6));
        return '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM yyyy').format(now)}';
      case 'Last 30 Days':
        final start = now.subtract(const Duration(days: 29));
        return '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM yyyy').format(now)}';
      case 'This Month':
        final start = DateTime(now.year, now.month, 1);
        return '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM yyyy').format(now)}';
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 0);
        return '${DateFormat('dd MMM').format(lastMonth)} - ${DateFormat('dd MMM yyyy').format(end)}';
      default:
        return '';
    }
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CALENDAR VIEW',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMMM yyyy').format(DateTime.now()),
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalendar(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days.map((day) {
            return SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: Text(
                  day.substring(0, 1),
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
          itemCount: 35,
          itemBuilder: (context, index) {
            final firstDay = DateTime(now.year, now.month, 1);
            final day = index - firstDay.weekday + 2;
            final isToday = day == now.day;
            final isInMonth = day > 0 && day <= DateTime(now.year, now.month + 1, 0).day;
            if (!isInMonth) {
              return const SizedBox();
            }
            final isSelected = _isDaySelected(day);
            return Container(
              decoration: BoxDecoration(
                color: isSelected ? decoration.colorScheme.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: isToday ? Border.all(color: decoration.colorScheme.primary, width: 1.5) : null,
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isToday
                        ? decoration.colorScheme.primary
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  bool _isDaySelected(int day) {
    if (ctrl.selectedDateRange.value != 'Custom Range') return false;
    if (ctrl.customStartDate.value == null || ctrl.customEndDate.value == null) return false;
    final now = DateTime.now();
    final testDate = DateTime(now.year, now.month, day);
    return testDate.isAfter(ctrl.customStartDate.value!.subtract(const Duration(days: 1))) && testDate.isBefore(ctrl.customEndDate.value!.add(const Duration(days: 1)));
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                ctrl.selectedDateRange.value = 'All Time';
                ctrl.customStartDate.value = null;
                ctrl.customEndDate.value = null;
              },
              style: TextButton.styleFrom(
                backgroundColor: decoration.colorScheme.primary.withOpacity(.1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Reset',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: decoration.colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ctrl.loadAppointments();
                Get.close(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: decoration.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Text('Apply Filter', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final initialDate = isStartDate ? ctrl.customStartDate.value ?? DateTime.now() : ctrl.customEndDate.value ?? DateTime.now();
    final selectedDate = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: decoration.colorScheme.primary,
            colorScheme: ColorScheme.light(primary: decoration.colorScheme.primary),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (selectedDate != null) {
      if (isStartDate) {
        ctrl.customStartDate.value = selectedDate;
        if (ctrl.customEndDate.value != null && ctrl.customEndDate.value!.isBefore(selectedDate)) {
          ctrl.customEndDate.value = null;
        }
      } else {
        if (ctrl.customStartDate.value == null || selectedDate == ctrl.customStartDate.value || selectedDate.isAfter(ctrl.customStartDate.value!)) {
          ctrl.customEndDate.value = selectedDate;
        } else {
          Get.snackbar('Invalid Date', 'End date must be after start date', backgroundColor: Colors.red.shade50, colorText: Colors.red, snackPosition: SnackPosition.TOP);
        }
      }
    }
  }
}
