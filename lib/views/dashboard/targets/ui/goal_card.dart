import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:therepist/models/goal_model.dart';

class GoalCard extends StatelessWidget {
  final GoalModel goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: 1)],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildGoalTitle(), const SizedBox(height: 12), _buildGoalDescription(), const SizedBox(height: 16), _buildProgressSection(), const SizedBox(height: 20), _buildFooter()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: goal.color.withOpacity(0.05),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: goal.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(
                goal.patientName.split(' ').map((n) => n[0]).join(),
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: goal.color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.patientName,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: _getPriorityColor(goal.priority).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(_getPriorityIcon(goal.priority), size: 10, color: _getPriorityColor(goal.priority)),
                          const SizedBox(width: 4),
                          Text(
                            goal.priority.toUpperCase(),
                            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: _getPriorityColor(goal.priority)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        goal.therapyType,
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildGoalTitle() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: goal.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(goal.icon, size: 18, color: goal.color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.title,
                style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text('${goal.currentValue.toInt()}/${goal.targetValue.toInt()} ${goal.unit}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalDescription() {
    return Text(
      goal.description,
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${goal.progressPercentage}% Complete',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: goal.color),
            ),
            Text('${goal.remainingDays} days left', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: goal.progress, backgroundColor: Colors.grey.shade200, color: goal.color, minHeight: 8),
        ),
        const SizedBox(height: 8),
        if (goal.milestones.isNotEmpty) ...[const SizedBox(height: 12), _buildMilestones()],
      ],
    );
  }

  Widget _buildMilestones() {
    final completedMilestones = goal.milestones.where((m) => m.isCompleted).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Milestones',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            Text('$completedMilestones/${goal.milestones.length} completed', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: goal.milestones.map((milestone) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: milestone.isCompleted ? const Color(0xFF10B981).withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: milestone.isCompleted ? const Color(0xFF10B981).withOpacity(0.3) : Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    milestone.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 12,
                    color: milestone.isCompleted ? const Color(0xFF10B981) : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    milestone.title,
                    style: GoogleFonts.poppins(fontSize: 11, color: milestone.isCompleted ? const Color(0xFF10B981) : Colors.grey.shade700, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.event_note_rounded, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Text('${goal.sessions.length} sessions', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(width: 12),
            Icon(Icons.timer_rounded, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(_formatFrequency(goal.frequency), style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        Row(
          children: [
            if (goal.status == 'active')
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: goal.color.withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.edit_rounded, size: 16, color: goal.color),
                  padding: EdgeInsets.zero,
                ),
              ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(18)),
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.visibility_rounded, size: 16, color: Colors.grey.shade700),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    IconData badgeIcon;

    switch (goal.status) {
      case 'active':
        badgeColor = const Color(0xFF10B981);
        badgeIcon = Icons.play_circle_fill_rounded;
        break;
      case 'upcoming':
        badgeColor = const Color(0xFFF59E0B);
        badgeIcon = Icons.schedule_rounded;
        break;
      case 'completed':
        badgeColor = const Color(0xFF3B82F6);
        badgeIcon = Icons.check_circle_rounded;
        break;
      case 'critical':
        badgeColor = const Color(0xFFEF4444);
        badgeIcon = Icons.warning_rounded;
        break;
      default:
        badgeColor = Colors.grey.shade600;
        badgeIcon = Icons.circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(badgeIcon, size: 12, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            goal.status.toUpperCase(),
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: badgeColor),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'critical':
        return const Color(0xFFEF4444);
      case 'high':
        return const Color(0xFFF59E0B);
      case 'medium':
        return const Color(0xFF3B82F6);
      case 'low':
        return const Color(0xFF6B7280);
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'critical':
        return Icons.warning_rounded;
      case 'high':
        return Icons.trending_up_rounded;
      case 'medium':
        return Icons.remove_rounded;
      case 'low':
        return Icons.trending_down_rounded;
      default:
        return Icons.circle_rounded;
    }
  }

  String _formatFrequency(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'biweekly':
        return 'Bi-weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return frequency;
    }
  }
}
