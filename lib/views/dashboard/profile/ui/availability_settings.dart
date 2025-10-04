import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/views/dashboard/profile/profile_ctrl.dart';

class AvailabilitySettings extends StatefulWidget {
  const AvailabilitySettings({super.key});

  @override
  State<AvailabilitySettings> createState() => _AvailabilitySettingsState();
}

class _AvailabilitySettingsState extends State<AvailabilitySettings> {
  final ProfileCtrl ctrl = Get.find<ProfileCtrl>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Clinic Availability',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
          ),
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
              ),
              icon: Icon(Icons.save, color: decoration.colorScheme.primary, size: 20),
              onPressed: () {
                ctrl.saveAvailability();
                Get.back();
                Get.snackbar('Success', 'Clinic availability saved successfully', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Working Days & Time Slots'),
            const SizedBox(height: 12),
            Text('Set multiple time slots for each working day', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 20),
            _buildDaysAvailability(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
    );
  }

  Widget _buildDaysAvailability() {
    return Column(
      children: [
        for (final day in ctrl.weekDays)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.calendar_today, color: decoration.colorScheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          day['name']!,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                      ),
                      Obx(() {
                        return Switch(
                          value: ctrl.availableDays.contains(day['name']),
                          activeColor: decoration.colorScheme.primary,
                          onChanged: (value) => ctrl.toggleDayAvailability(day['name']!, value),
                        );
                      }),
                    ],
                  ),
                ),
                Obx(() {
                  if (!ctrl.availableDays.contains(day['name']!)) {
                    return const SizedBox.shrink();
                  }
                  final daySlots = ctrl.getTimeSlotsForDay(day['name'].toString());
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (daySlots.isNotEmpty) ...[_buildSlotsList(day['name']!, daySlots), const SizedBox(height: 12)],
                        _buildAddSlotButton(day['name']!),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSlotsList(String dayName, List<Map<String, TimeOfDay>> slots) {
    return Column(
      children: [
        for (int i = 0; i < slots.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: decoration.colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildCompactTimePicker('From', slots[i]['start']!, (time) => ctrl.updateSlotTime(dayName, i, 'start', time))),
                const SizedBox(width: 8),
                Expanded(child: _buildCompactTimePicker('To', slots[i]['end']!, (time) => ctrl.updateSlotTime(dayName, i, 'end', time))),
                const SizedBox(width: 8),
                if (slots.length > 1)
                  IconButton(
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      padding: WidgetStatePropertyAll(const EdgeInsets.all(4)),
                      backgroundColor: WidgetStatePropertyAll(Colors.red.withOpacity(0.1)),
                    ),
                    icon: Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    onPressed: () => ctrl.removeTimeSlot(dayName, i),
                    tooltip: 'Remove slot',
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCompactTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onTimeChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        InkWell(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: Get.context!,
              initialTime: time,
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: decoration.colorScheme.primary)),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onTimeChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(time), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddSlotButton(String dayName) {
    return OutlinedButton.icon(
      icon: Icon(Icons.add, size: 16, color: decoration.colorScheme.primary),
      onPressed: () => ctrl.addTimeSlot(dayName),
      style: OutlinedButton.styleFrom(
        foregroundColor: decoration.colorScheme.primary,
        side: BorderSide(color: decoration.colorScheme.primary.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      label: Text('Add Time Slot', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
  }
}
