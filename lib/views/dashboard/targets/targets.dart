import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:therepist/models/goal_model.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/views/dashboard/targets/targets_ctrl.dart';
import 'package:therepist/views/dashboard/targets/ui/goal_card.dart';

class Targets extends StatefulWidget {
  const Targets({super.key});

  @override
  State<Targets> createState() => _TargetsState();
}

class _TargetsState extends State<Targets> {
  final TargetsCtrl goalsCtrl = Get.put(TargetsCtrl());
  final ScrollController _scrollController = ScrollController();
  final PageController _statsController = PageController(viewportFraction: 0.85);
  int _currentStatPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (goalsCtrl.goals.isEmpty) {
        goalsCtrl.loadGoals();
      }
    });
    _statsController.addListener(() {
      setState(() {
        _currentStatPage = _statsController.page?.round() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, appBar: _buildAppBar(), body: _buildBody());
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 70,
      backgroundColor: decoration.colorScheme.primary,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Goals', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
          Obx(() {
            final stats = goalsCtrl.getStats();
            return Text('${stats['active']} Active • ${stats['patients']} Patients', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400));
          }),
        ],
      ),
      centerTitle: false,
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
          backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
        ),
        icon: Icon(Icons.arrow_back, color: decoration.colorScheme.primary),
        onPressed: () => Get.close(1),
      ),
      actions: [
        IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
          ),
          icon: Icon(Icons.search, color: decoration.colorScheme.primary, size: 20),
          onPressed: () => _showSearchDialog(),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildStatsOverview(),
        const SizedBox(height: 16),
        _buildEnhancedFilterRow(),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() {
            if (goalsCtrl.isLoading) {
              return _buildShimmerLoading();
            }
            final filteredGoals = goalsCtrl.filteredGoals;
            if (filteredGoals.isEmpty) {
              return _buildEmptyState();
            }
            return RefreshIndicator(
              onRefresh: () => goalsCtrl.loadGoals(),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final goal = filteredGoals[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: index == filteredGoals.length - 1 ? 20 : 12),
                          child: GoalCard(goal: goal),
                        );
                      }, childCount: filteredGoals.length),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      color: Colors.white,
      child: Obx(() {
        if (goalsCtrl.isLoading) {
          return _buildStatsShimmer();
        }
        final stats = goalsCtrl.getStats();
        final List<StatCardData> statCards = [
          StatCardData(
            title: 'Active Goals',
            value: '${stats['active']}',
            subtitle: 'In Progress',
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF10B981),
            gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
          ),
          StatCardData(
            title: 'Completed',
            value: '${stats['completed']}',
            subtitle: 'This Month',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF3B82F6),
            gradient: [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
          ),
          StatCardData(
            title: 'Patient Adherence',
            value: '${(stats['adherence'] * 100).toStringAsFixed(0)}%',
            subtitle: 'Overall Rate',
            icon: Icons.psychology_rounded,
            color: const Color(0xFF8B5CF6),
            gradient: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
          ),
          StatCardData(
            title: 'Avg. Progress',
            value: '${(stats['avgProgress'] * 100).toStringAsFixed(0)}%',
            subtitle: 'Per Goal',
            icon: Icons.bar_chart_rounded,
            color: const Color(0xFFF59E0B),
            gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 130,
              child: PageView.builder(
                controller: _statsController,
                itemCount: statCards.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentStatPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final stat = statCards[index];
                  return Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16), child: _buildStatCard(stat));
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                statCards.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: _currentStatPage == index ? const Color(0xFF3B82F6) : Colors.grey.shade300),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard(StatCardData stat) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: stat.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: stat.color.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 16,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Icon(stat.icon, size: 20, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    stat.value,
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    stat.subtitle,
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            Text(stat.title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.9))),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 120,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedFilterRow() {
    final filters = [
      FilterOption('active', 'Active', Icons.play_circle_fill_rounded, const Color(0xFF10B981)),
      FilterOption('upcoming', 'Upcoming', Icons.schedule_rounded, const Color(0xFFF59E0B)),
      FilterOption('completed', 'Completed', Icons.check_circle_rounded, const Color(0xFF3B82F6)),
      FilterOption('critical', 'Critical', Icons.warning_rounded, const Color(0xFFEF4444)),
      FilterOption('all', 'All', Icons.all_inclusive_rounded, const Color(0xFF8B5CF6)),
    ];

    return Obx(() {
      return Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: filters.map((filter) {
            final isSelected = goalsCtrl.selectedFilter == filter.value;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => goalsCtrl.setFilter(filter.value),
                  borderRadius: BorderRadius.circular(25),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? filter.color.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: isSelected ? filter.color : Colors.grey.shade300, width: isSelected ? 1.5 : 1),
                    ),
                    child: Row(
                      children: [
                        Icon(filter.icon, size: 16, color: isSelected ? filter.color : Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          filter.label,
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? filter.color : Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildShimmerCard()), childCount: 6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleShimmer(size: 40),
                SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [RectangleShimmer(width: 140, height: 16), SizedBox(height: 8), RectangleShimmer(width: 100, height: 12)]),
                ),
              ],
            ),
            SizedBox(height: 16),
            RectangleShimmer(width: double.infinity, height: 8),
            SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [RectangleShimmer(width: 60, height: 12), RectangleShimmer(width: 80, height: 12)]),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [CircleShimmer(size: 24), SizedBox(width: 8), RectangleShimmer(width: 80, height: 12)]),
                Row(children: [RectangleShimmer(width: 60, height: 12), SizedBox(width: 8), CircleShimmer(size: 24)]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_outlined, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'No Therapy Goals',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              goalsCtrl.selectedFilter == 'active' ? 'Create your first therapy goal for a patient' : 'No goals found with current filter',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showSearch(
      context: context,
      delegate: _GoalSearchDelegate(goalsCtrl: goalsCtrl),
    );
  }
}

class FilterOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  FilterOption(this.value, this.label, this.icon, this.color);
}

class StatCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  StatCardData({required this.title, required this.value, required this.subtitle, required this.icon, required this.color, required this.gradient});
}

class CircleShimmer extends StatelessWidget {
  final double size;

  const CircleShimmer({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    );
  }
}

class RectangleShimmer extends StatelessWidget {
  final double width;
  final double height;

  const RectangleShimmer({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
    );
  }
}

class _GoalSearchDelegate extends SearchDelegate {
  final TargetsCtrl goalsCtrl;

  _GoalSearchDelegate({required this.goalsCtrl});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
          backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
        ),
        icon: const Icon(Icons.clear, color: Colors.black87, size: 20),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
      SizedBox(width: 10),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
        backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
      ),
      icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = goalsCtrl.goals.where((goal) {
      return goal.title.toLowerCase().contains(query.toLowerCase()) ||
          goal.patientName.toLowerCase().contains(query.toLowerCase()) ||
          goal.therapyType.toLowerCase().contains(query.toLowerCase()) ||
          goal.category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildResultsList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty ? goalsCtrl.goals.take(5).toList() : goalsCtrl.goals.where((goal) => goal.title.toLowerCase().contains(query.toLowerCase())).take(5).toList();

    return _buildResultsList(suggestions);
  }

  Widget _buildResultsList(List<GoalModel> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No goals found', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Try searching by patient name or therapy type', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final goal = results[index];
        return GoalCard(goal: goal);
      },
    );
  }
}
