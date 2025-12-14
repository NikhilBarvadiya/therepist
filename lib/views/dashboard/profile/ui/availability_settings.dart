import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/utils/toaster.dart';
import 'package:therepist/views/dashboard/profile/profile_ctrl.dart';

class AvailabilitySettings extends StatefulWidget {
  const AvailabilitySettings({super.key});

  @override
  State<AvailabilitySettings> createState() => _AvailabilitySettingsState();
}

class _AvailabilitySettingsState extends State<AvailabilitySettings> {
  final ProfileCtrl ctrl = Get.find<ProfileCtrl>();
  final ScrollController _scrollController = ScrollController();
  var isSaving = false.obs;
  final List<String> _expandedDays = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: decoration.colorScheme.primary,
        title: Text('Availability', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        leading: IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
          ),
          icon: Icon(Icons.arrow_back, color: decoration.colorScheme.primary, size: 20),
          onPressed: () => Get.close(1),
        ),
        actions: [
          Obx(
            () => isSaving.value
                ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: decoration.colorScheme.onPrimary)),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ElevatedButton.icon(
                      onPressed: _saveAvailability,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: decoration.colorScheme.onPrimary,
                        foregroundColor: decoration.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: Icon(Icons.save_outlined, size: 18),
                      label: Text('Save Changes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return _buildShimmerLoading();
        }
        return Column(
          children: [
            _buildStatsHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ctrl.loadProfile(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [_buildWeeklyScheduleSection(), const SizedBox(height: 20), _buildQuickActionsSection(), const SizedBox(height: 20), _buildInfoCard(), const SizedBox(height: 32)],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(3, (index) => _buildShimmerStatItem())),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 24, height: 24, color: Colors.grey.shade200),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 16, color: Colors.grey.shade200),
                    const SizedBox(height: 8),
                    Container(width: double.infinity, height: 12, color: Colors.grey.shade200),
                    const SizedBox(height: 4),
                    Container(width: double.infinity, height: 12, color: Colors.grey.shade200),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...List.generate(7, (index) => _buildShimmerDayCard()),
      ],
    );
  }

  Widget _buildShimmerStatItem() {
    return Column(
      children: [
        Container(width: 60, height: 30, color: Colors.grey.shade200),
        const SizedBox(height: 8),
        Container(width: 40, height: 12, color: Colors.grey.shade200),
      ],
    );
  }

  Widget _buildShimmerDayCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 80, height: 16, color: Colors.grey.shade200),
                      const SizedBox(height: 4),
                      Container(width: 60, height: 12, color: Colors.grey.shade200),
                    ],
                  ),
                ),
                Container(width: 40, height: 24, color: Colors.grey.shade200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    final activeDays = ctrl.availableDays.length;
    final totalSlots = ctrl.daySchedules.values.fold<int>(0, (sum, slots) => sum + slots.length);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          _buildStatItem(icon: Icons.calendar_today_outlined, value: totalSlots.toString(), label: 'Total Slots'),
          const SizedBox(width: 20),
          _buildStatItem(icon: Icons.check_circle_outline, value: activeDays.toString(), label: 'Active Days'),
          const SizedBox(width: 20),
          _buildStatItem(icon: Icons.access_time, value: activeDays > 0 ? (totalSlots / activeDays).toStringAsFixed(1) : '0.0', label: 'Avg/Day'),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label}) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: decoration.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: decoration.colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: decoration.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: decoration.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: decoration.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Your Availability',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  'Set time slots when you\'re available for appointments. '
                  'Patients can only book during these time slots. '
                  'Add multiple slots per day to increase booking opportunities.',
                  style: TextStyle(fontSize: 12, height: 1.5, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Weekly Schedule',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const Spacer(),
            Obx(() {
              final activeDays = ctrl.availableDays.length;
              final totalSlots = ctrl.daySchedules.values.fold<int>(0, (sum, slots) => sum + slots.length);
              return Text('$totalSlots slots across $activeDays days', style: TextStyle(fontSize: 12, color: Colors.grey.shade600));
            }),
          ],
        ),
        const SizedBox(height: 16),
        ...ctrl.weekDays.map((day) => _buildDayCard(day)),
      ],
    );
  }

  Widget _buildDayCard(Map<String, String> dayData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dayName = dayData['name']!;
    final dayKey = dayData['key']!;
    final isAvailable = ctrl.availableDays.contains(dayName);
    final slotsCount = ctrl.getTimeSlotsForDay(dayName).length;
    final isExpanded = _expandedDays.contains(dayKey);
    final dayColor = colorScheme.primary.withOpacity(0.9);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedDays.remove(dayKey);
                } else {
                  _expandedDays.add(dayKey);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAvailable ? dayColor.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isExpanded ? Radius.zero : const Radius.circular(16),
                  bottomRight: isExpanded ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: isAvailable ? dayColor : Colors.grey.shade100, shape: BoxShape.circle),
                    child: Icon(_getDayIcon(dayKey), color: isAvailable ? Colors.white : Colors.grey.shade600, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isAvailable ? dayColor : Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAvailable ? '$slotsCount ${slotsCount == 1 ? 'slot' : 'slots'} available' : 'No slots set',
                          style: TextStyle(fontSize: 12, fontWeight: isAvailable ? FontWeight.w600 : null),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Switch.adaptive(
                        value: isAvailable,
                        activeColor: dayColor,
                        onChanged: (value) {
                          ctrl.toggleDayAvailability(dayName, value);
                          if (value && !_expandedDays.contains(dayKey)) {
                            _expandedDays.add(dayKey);
                          }
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey.shade500),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && isAvailable) _buildSlotsList(dayName, dayKey, dayColor),
        ],
      ),
    );
  }

  Widget _buildSlotsList(String dayName, String dayKey, Color dayColor) {
    final slots = ctrl.getTimeSlotsForDay(dayName);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Slots',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          if (slots.isEmpty) _buildEmptySlotsState(dayColor) else ..._buildSlotItems(dayName, slots, dayColor),
          const SizedBox(height: 16),
          _buildAddSlotButton(dayName, dayColor),
        ],
      ),
    );
  }

  Widget _buildEmptySlotsState(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.schedule_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No time slots added',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first time slot for this day',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSlotItems(String dayName, List<Map<String, TimeOfDay>> slots, Color dayColor) {
    return List.generate(slots.length, (index) {
      return _buildSlotItem(dayName, index, slots[index], dayColor);
    });
  }

  Widget _buildSlotItem(String dayName, int index, Map<String, TimeOfDay> slot, Color dayColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: dayColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: dayColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildTimePicker(dayName, index, 'start', slot['start']!, dayColor)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTimePicker(dayName, index, 'end', slot['end']!, dayColor)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (index != -1) {
                            ctrl.removeTimeSlot(dayName, index);
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: Icon(Icons.delete_outline, size: 18),
                        label: Text('Remove', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(String dayName, int index, String type, TimeOfDay currentTime, Color dayColor) {
    final label = type == 'start' ? 'START TIME' : 'END TIME';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: currentTime,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    timePickerTheme: TimePickerThemeData(
                      backgroundColor: Colors.white,
                      hourMinuteTextColor: Colors.black87,
                      hourMinuteColor: dayColor.withOpacity(0.1),
                      dayPeriodTextColor: Colors.black87,
                      dayPeriodColor: dayColor.withOpacity(0.1),
                      dialHandColor: dayColor,
                      dialBackgroundColor: Colors.grey.shade50,
                      hourMinuteTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      dayPeriodTextStyle: const TextStyle(fontSize: 14),
                    ),
                    colorScheme: ColorScheme.light(primary: dayColor, onPrimary: Colors.white),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && mounted) {
              ctrl.updateSlotTime(dayName, index, type, picked);
              setState(() {});
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(currentTime),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                Icon(Icons.access_time, size: 16, color: dayColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddSlotButton(String dayName, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ctrl.addTimeSlot(dayName);
          setState(() {});
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        icon: Icon(Icons.add, size: 20),
        label: Text('Add Time Slot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: decoration.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuickActionButton(icon: Icons.weekend_outlined, label: 'Setup Weekdays', description: '9 AM - 6 PM', onTap: _setupWeekdays),
          const SizedBox(height: 10),
          _buildQuickActionButton(icon: Icons.weekend, label: 'Setup Weekend', description: '10 AM - 4 PM', onTap: _setupWeekend),
          const SizedBox(height: 10),
          _buildQuickActionButton(icon: Icons.repeat, label: 'Copy Monday', description: 'Copy to all weekdays', onTap: _copyMondayToAll),
          const SizedBox(height: 10),
          _buildQuickActionButton(icon: Icons.clear_all, label: 'Clear All', description: 'Remove all time slots', onTap: _showClearAllConfirmation),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({required IconData icon, required String label, required String description, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: decoration.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setupWeekdays() {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    for (final day in weekdays) {
      if (!ctrl.availableDays.contains(day)) {
        ctrl.toggleDayAvailability(day, true);
      }
      ctrl.daySchedules[day] = [
        {'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 18, minute: 0)},
      ];
    }
    setState(() {});
    toaster.info('Monday to Friday set with 9 AM - 6 PM');
  }

  void _setupWeekend() {
    final weekend = ['Saturday', 'Sunday'];
    for (final day in weekend) {
      if (!ctrl.availableDays.contains(day)) {
        ctrl.toggleDayAvailability(day, true);
      }
      ctrl.daySchedules[day] = [
        {'start': const TimeOfDay(hour: 10, minute: 0), 'end': const TimeOfDay(hour: 16, minute: 0)},
      ];
    }
    setState(() {});
    toaster.info('Saturday & Sunday set with 10 AM - 4 PM');
  }

  void _copyMondayToAll() {
    if (!ctrl.availableDays.contains('Monday')) {
      toaster.error('Monday must be enabled first');
      return;
    }
    final mondaySlots = List<Map<String, TimeOfDay>>.from(ctrl.getTimeSlotsForDay('Monday'));
    final weekdays = ['Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    for (final day in weekdays) {
      if (!ctrl.availableDays.contains(day)) {
        ctrl.toggleDayAvailability(day, true);
      }
      ctrl.daySchedules[day] = List<Map<String, TimeOfDay>>.from(mondaySlots);
    }
    setState(() {});
    toaster.info('Monday slots copied to all weekdays');
  }

  void _showClearAllConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All Time Slots?'),
        content: const Text('This will remove all time slots from all days. This action cannot be undone.'),
        actions: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: OutlinedButton(
                onPressed: () => Get.close(1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                child: Text('Go Back', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          Expanded(
            child: ElevatedButton(
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
                Get.close(1);
                setState(() {});
                toaster.info('All time slots have been reset');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                elevation: 0,
              ),
              child: Text('Yes, Clear', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAvailability() async {
    try {
      isSaving.value = true;
      await ctrl.saveAvailability();
      Get.close(1);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save availability: ${e.toString()}', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  IconData _getDayIcon(String dayKey) {
    switch (dayKey) {
      case 'mon':
        return Icons.calendar_view_week;
      case 'tue':
        return Icons.view_week;
      case 'wed':
        return Icons.calendar_month;
      case 'thu':
        return Icons.today;
      case 'fri':
        return Icons.weekend;
      case 'sat':
        return Icons.weekend;
      case 'sun':
        return Icons.weekend;
      default:
        return Icons.calendar_today;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
