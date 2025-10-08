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
  final ScrollController _scrollController = ScrollController();
  var isLoading = false.obs;

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
          Obx(
            () => isLoading.value
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: decoration.colorScheme.primary)),
                  ).paddingOnly(right: 8)
                : Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                        backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
                      ),
                      icon: Icon(Icons.save, color: decoration.colorScheme.primary, size: 20),
                      onPressed: _saveAvailability,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Working Days & Time Slots',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text('Set your clinic working days and multiple time slots for appointments', style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4)),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(controller: _scrollController, padding: const EdgeInsets.all(20), children: [_buildDaysAvailability(), const SizedBox(height: 20), _buildQuickActions()]);
            }),
          ),
        ],
      ),
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
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
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
                        decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.calendar_today, color: decoration.colorScheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day['name']!,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                            const SizedBox(height: 2),
                            Obx(() {
                              final isAvailable = ctrl.availableDays.contains(day['name']);
                              return Text(
                                isAvailable ? 'Available' : 'Not Available',
                                style: TextStyle(fontSize: 12, color: isAvailable ? Colors.green : Colors.grey[500], fontWeight: FontWeight.w500),
                              );
                            }),
                          ],
                        ),
                      ),
                      Obx(() {
                        return Switch(
                          value: ctrl.availableDays.contains(day['name']),
                          activeColor: decoration.colorScheme.primary,
                          onChanged: (value) {
                            ctrl.toggleDayAvailability(day['name']!, value);
                            setState(() {});
                          },
                        );
                      }),
                    ],
                  ),
                ),
                Obx(() {
                  if (!ctrl.availableDays.contains(day['name']!)) {
                    return const SizedBox.shrink();
                  }
                  final daySlots = ctrl.getTimeSlotsForDay(day['name']!);
                  return Container(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (daySlots.isNotEmpty) ...[_buildSlotsHeader(), const SizedBox(height: 8), _buildSlotsList(day['name']!, daySlots), const SizedBox(height: 12)],
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

  Widget _buildSlotsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 36, child: Text('#', style: _headerTextStyle())),
          const SizedBox(width: 12),
          Expanded(child: Text('Start Time', style: _headerTextStyle())),
          const SizedBox(width: 8),
          Expanded(child: Text('End Time', style: _headerTextStyle())),
          const SizedBox(width: 8),
          SizedBox(width: 40, child: Text('Action', style: _headerTextStyle())),
        ],
      ),
    );
  }

  TextStyle _headerTextStyle() {
    return TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600);
  }

  Widget _buildSlotsList(String dayName, List<Map<String, TimeOfDay>> slots) {
    return Column(
      children: [
        for (int i = 0; i < slots.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.only(left: 10, top: 12, bottom: 12, right: 2),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Expanded(child: _buildTimePicker('Start', slots[i]['start']!, (time) => ctrl.updateSlotTime(dayName, i, 'start', time))),
                const SizedBox(width: 8),
                Expanded(child: _buildTimePicker('End', slots[i]['end']!, (time) => ctrl.updateSlotTime(dayName, i, 'end', time))),
                if (slots.length > 1) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      padding: WidgetStatePropertyAll(EdgeInsets.zero),
                      backgroundColor: WidgetStatePropertyAll(Colors.red.withOpacity(0.1)),
                    ),
                    icon: Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    onPressed: () => _showDeleteConfirmation(dayName, i),
                    tooltip: 'Remove time slot',
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onTimeChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: time,
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(primary: decoration.colorScheme.primary, onPrimary: Colors.white),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && mounted) {
              onTimeChanged(picked);
              setState(() {});
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(time),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
                Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddSlotButton(String dayName) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(Icons.add, size: 18, color: decoration.colorScheme.primary),
        onPressed: () {
          ctrl.addTimeSlot(dayName);
          setState(() {});
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
          });
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: decoration.colorScheme.primary,
          side: BorderSide(color: decoration.colorScheme.primary.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          backgroundColor: Colors.white,
        ),
        label: Text('Add Time Slot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.weekend_outlined, size: 18, color: decoration.colorScheme.primary),
                  onPressed: _enableWeekdays,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: decoration.colorScheme.primary,
                    side: BorderSide(color: decoration.colorScheme.primary.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  label: const Text('Weekdays', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.clear_all, size: 18, color: Colors.red),
                  onPressed: _clearAllSlots,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  label: const Text('Clear All', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _enableWeekdays() {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    for (final day in weekdays) {
      if (!ctrl.availableDays.contains(day)) {
        ctrl.toggleDayAvailability(day, true);
      }
    }
    setState(() {});
    Get.snackbar('Weekdays Enabled', 'Monday to Friday have been set as working days', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
  }

  void _clearAllSlots() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All Time Slots?'),
        content: const Text('This will remove all time slots from all days. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              for (final day in ctrl.weekDays) {
                final dayName = day['name']!;
                final slots = ctrl.getTimeSlotsForDay(dayName);
                while (slots.length > 1) {
                  ctrl.removeTimeSlot(dayName, slots.length - 1);
                }
                if (slots.isNotEmpty) {
                  ctrl.updateSlotTime(dayName, 0, 'start', const TimeOfDay(hour: 9, minute: 0));
                  ctrl.updateSlotTime(dayName, 0, 'end', const TimeOfDay(hour: 17, minute: 0));
                }
              }
              Get.back();
              setState(() {});
              Get.snackbar('Cleared', 'All time slots have been reset', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String dayName, int slotIndex) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Time Slot?'),
        content: const Text('Are you sure you want to remove this time slot?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ctrl.removeTimeSlot(dayName, slotIndex);
              Get.back();
              setState(() {});
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAvailability() async {
    try {
      isLoading.value = true;
      await ctrl.saveAvailability();
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save availability: ${e.toString()}', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
