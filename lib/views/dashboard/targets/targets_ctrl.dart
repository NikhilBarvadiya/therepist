import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:therepist/models/goal_model.dart';
import 'package:therepist/utils/toaster.dart';

class TargetsCtrl extends GetxController {
  static TargetsCtrl get to => Get.find();

  final RxList<GoalModel> _goals = <GoalModel>[].obs;
  final RxString _selectedFilter = 'active'.obs;
  final RxBool _isLoading = false.obs;

  List<GoalModel> get goals => _goals;

  String get selectedFilter => _selectedFilter.value;

  bool get isLoading => _isLoading.value;

  List<GoalModel> get filteredGoals {
    List<GoalModel> result = _goals.where((goal) {
      if (selectedFilter == 'active') return goal.status == 'active';
      if (selectedFilter == 'upcoming') return goal.status == 'upcoming';
      if (selectedFilter == 'completed') return goal.status == 'completed';
      if (selectedFilter == 'critical') return goal.priority == 'critical';
      if (selectedFilter == 'all') return true;
      return goal.therapyType == selectedFilter || goal.category == selectedFilter;
    }).toList();

    // Sort by priority and due date
    result.sort((a, b) {
      final priorityOrder = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3};
      final priorityA = priorityOrder[a.priority] ?? 3;
      final priorityB = priorityOrder[b.priority] ?? 3;
      if (priorityA != priorityB) return priorityA.compareTo(priorityB);
      return a.endDate.compareTo(b.endDate);
    });

    return result;
  }

  List<GoalModel> get activeTargets => _goals.where((t) => t.isActive && !t.isCompleted && !t.isExpired).toList();

  @override
  void onInit() {
    super.onInit();
    loadGoals();
  }

  Future<void> loadGoals() async {
    _isLoading.value = true;
    try {
      await _addSampleGoals();
    } catch (e) {
      toaster.error('Failed to load goals: $e');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  Map<String, dynamic> getStats() {
    final active = _goals.where((g) => g.status == 'active').length;
    final upcoming = _goals.where((g) => g.status == 'upcoming').length;
    final completed = _goals.where((g) => g.status == 'completed').length;
    final critical = _goals.where((g) => g.priority == 'critical').length;

    // Calculate unique patients
    final patientIds = _goals.map((g) => g.patientId).toSet();

    // Calculate average progress
    double totalProgress = 0;
    int activeCount = 0;
    for (var goal in _goals.where((g) => g.status == 'active')) {
      totalProgress += goal.progress;
      activeCount++;
    }
    final avgProgress = activeCount > 0 ? totalProgress / activeCount : 0;

    // Calculate adherence rate (sessions completed / sessions scheduled)
    int totalSessions = 0;
    int completedSessions = 0;
    for (var goal in _goals) {
      totalSessions += goal.sessions.length;
      completedSessions += goal.sessions.where((s) => s.progressValue > 0).length;
    }
    final adherence = totalSessions > 0 ? completedSessions / totalSessions : 0;

    return {
      'total': _goals.length,
      'active': active,
      'upcoming': upcoming,
      'completed': completed,
      'critical': critical,
      'patients': patientIds.length,
      'avgProgress': avgProgress,
      'adherence': adherence,
    };
  }

  Future<void> setFilter(String filter) async {
    _selectedFilter.value = filter;
  }

  Future<void> _addSampleGoals() async {
    final sampleGoals = [
      GoalModel(
        id: '1',
        patientId: 'p001',
        patientName: 'John Smith',
        patientImage: '',
        title: 'Reduce Anxiety Symptoms',
        description: 'Decrease anxiety severity from moderate to mild within 8 sessions using CBT techniques',
        therapyType: 'CBT',
        category: 'anxiety',
        currentValue: 6,
        targetValue: 8,
        unit: 'sessions',
        color: const Color(0xFF10B981),
        icon: Icons.psychology_rounded,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 30)),
        frequency: 'weekly',
        milestones: [
          GoalMilestone(
            id: 'm1',
            title: 'Assessment Complete',
            description: 'Initial anxiety assessment completed',
            targetValue: 1,
            isCompleted: true,
            notes: 'Patient showed moderate anxiety levels',
          ),
          GoalMilestone(
            id: 'm2',
            title: 'CBT Techniques Learned',
            description: 'Patient demonstrates understanding of CBT techniques',
            targetValue: 4,
            isCompleted: true,
            notes: 'Good progress with thought challenging',
          ),
        ],
        sessions: List.generate(
          6,
          (i) => SessionRecord(
            id: 's$i',
            date: DateTime.now().subtract(Duration(days: (6 - i) * 7)),
            progressValue: 1.0,
            notes: 'Session ${i + 1} completed',
            therapistNotes: 'Patient engaged well',
            attachments: [],
          ),
        ),
        status: 'active',
        priority: 'high',
        notes: 'Patient shows good progress with exposure therapy',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        completedDates: List.generate(6, (i) => DateTime.now().subtract(Duration(days: (6 - i) * 7))),
        isActive: true,
        isCompleted: false,
        isExpired: false,
      ),
      GoalModel(
        id: '2',
        patientId: 'p002',
        patientName: 'Sarah Johnson',
        patientImage: '',
        title: 'Trauma Processing',
        description: 'Process traumatic memories using EMDR therapy over 12 sessions',
        therapyType: 'EMDR',
        category: 'trauma',
        currentValue: 3,
        targetValue: 12,
        unit: 'sessions',
        color: const Color(0xFF8B5CF6),
        icon: Icons.health_and_safety_rounded,
        startDate: DateTime.now().subtract(const Duration(days: 14)),
        endDate: DateTime.now().add(const Duration(days: 70)),
        frequency: 'biweekly',
        milestones: [
          GoalMilestone(id: 'm1', title: 'Stabilization Phase', description: 'Complete stabilization techniques', targetValue: 2, isCompleted: true, notes: 'Patient learned grounding techniques'),
        ],
        sessions: List.generate(
          3,
          (i) => SessionRecord(
            id: 's${i + 10}',
            date: DateTime.now().subtract(Duration(days: (3 - i) * 14)),
            progressValue: 0.8 + i * 0.1,
            notes: 'EMDR session ${i + 1}',
            therapistNotes: 'Processing initiated',
            attachments: [],
          ),
        ),
        status: 'active',
        priority: 'critical',
        notes: 'Patient experiences high distress during sessions - proceed with caution',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        completedDates: List.generate(3, (i) => DateTime.now().subtract(Duration(days: (3 - i) * 14))),
        isActive: true,
        isCompleted: false,
        isExpired: false,
      ),
      GoalModel(
        id: '3',
        patientId: 'p003',
        patientName: 'Michael Brown',
        patientImage: '',
        title: 'Depression Management',
        description: 'Improve mood and activity levels using behavioral activation',
        therapyType: 'BA',
        category: 'depression',
        currentValue: 10,
        targetValue: 10,
        unit: 'sessions',
        color: const Color(0xFF3B82F6),
        icon: Icons.mood_rounded,
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        endDate: DateTime.now().subtract(const Duration(days: 7)),
        frequency: 'weekly',
        milestones: [
          GoalMilestone(id: 'm1', title: 'Activity Scheduling', description: 'Implement daily activity schedule', targetValue: 4, isCompleted: true, notes: 'Patient shows increased engagement'),
          GoalMilestone(id: 'm2', title: 'Cognitive Restructuring', description: 'Challenge negative thoughts', targetValue: 8, isCompleted: true, notes: 'Significant improvement in mood'),
        ],
        sessions: List.generate(
          10,
          (i) => SessionRecord(
            id: 's${i + 20}',
            date: DateTime.now().subtract(Duration(days: (10 - i) * 7)),
            progressValue: 1.0,
            notes: 'Weekly session ${i + 1}',
            therapistNotes: 'Consistent progress observed',
            attachments: [],
          ),
        ),
        status: 'completed',
        priority: 'medium',
        notes: 'Goal successfully completed. Patient discharged with maintenance plan',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        completedAt: DateTime.now().subtract(const Duration(days: 7)),
        completedDates: List.generate(10, (i) => DateTime.now().subtract(Duration(days: (10 - i) * 7))),
        isActive: false,
        isCompleted: true,
        isExpired: false,
      ),
      GoalModel(
        id: '4',
        patientId: 'p004',
        patientName: 'Emma Wilson',
        patientImage: '',
        title: 'Social Anxiety Reduction',
        description: 'Increase social engagement and reduce avoidance behaviors',
        therapyType: 'Exposure',
        category: 'social_anxiety',
        currentValue: 2,
        targetValue: 8,
        unit: 'sessions',
        color: const Color(0xFFF59E0B),
        icon: Icons.group_rounded,
        startDate: DateTime.now().add(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 59)),
        frequency: 'weekly',
        milestones: [],
        sessions: [],
        status: 'upcoming',
        priority: 'medium',
        notes: 'Scheduled to start next week. Patient has completed assessment',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        completedDates: [],
        isActive: false,
        isCompleted: false,
        isExpired: false,
      ),
    ];

    _goals.assignAll(sampleGoals);
  }
}
