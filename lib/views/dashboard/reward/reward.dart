import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:therepist/models/reward_model.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/views/dashboard/reward/reward_ctrl.dart';

class Rewards extends StatefulWidget {
  const Rewards({super.key});

  @override
  State<Rewards> createState() => _RewardsState();
}

class _RewardsState extends State<Rewards> {
  final RewardCtrl rewardCtrl = Get.put(RewardCtrl());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (rewardCtrl.availableRewards.isEmpty) {
        rewardCtrl.loadRewards();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: decoration.colorScheme.primary,
          title: Text('Rewards & Points', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
          centerTitle: false,
          elevation: 0,
          leading: IconButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
              backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
            ),
            icon: Icon(Icons.arrow_back, color: decoration.colorScheme.primary),
            onPressed: () => Get.close(1),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.card_giftcard, size: 20), SizedBox(width: 8), Text('My Rewards')]),
                      ),
                      Tab(
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.history, size: 20), SizedBox(width: 8), Text('Points History')]),
                      ),
                    ],
                    labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
                    unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
                    indicator: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Get.theme.colorScheme.surface),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Get.theme.colorScheme.primary,
                    unselectedLabelColor: Get.theme.colorScheme.surface,
                    splashFactory: NoSplash.splashFactory,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        body: TabBarView(children: [_buildRewardsTab(), _buildHistoryTab()]),
      ),
    );
  }

  Widget _buildRewardsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await rewardCtrl.loadRewards();
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildEnhancedPointsCard(),
            const SizedBox(height: 10),
            _buildEnhancedCategoryFilter(),
            const SizedBox(height: 20),
            Obx(() {
              if (rewardCtrl.isLoading) {
                return _buildShimmerGrid();
              }
              final filteredRewards = rewardCtrl.filteredRewards;
              if (filteredRewards.isEmpty) {
                return _buildEmptyRewardsState();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Rewards',
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          Text('${filteredRewards.length} available', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.5),
                      itemCount: filteredRewards.length,
                      itemBuilder: (context, index) {
                        final reward = filteredRewards[index];
                        return _buildEnhancedRewardCard(reward);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPointsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Get.theme.colorScheme.primary, Get.theme.colorScheme.primary.withOpacity(0.9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Get.theme.colorScheme.primary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: 1)],
      ),
      child: Obx(() {
        final balance = rewardCtrl.pointsBalance;
        final stats = rewardCtrl.getRewardStats();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Points',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          balance.availablePoints.toString(),
                          style: GoogleFonts.poppins(fontSize: 42, fontWeight: FontWeight.w700, color: Colors.white, height: 0.9),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            'Points',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.star_rounded, color: Colors.white, size: 34),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(height: 1, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildEnhancedMiniStat(icon: Icons.trending_up_rounded, value: '${balance.earnedPoints}', label: 'Earned', iconColor: Colors.green.shade100),
                _buildEnhancedMiniStat(icon: Icons.shopping_cart_rounded, value: '${balance.spentPoints}', label: 'Spent', iconColor: Colors.orange.shade100),
                _buildEnhancedMiniStat(icon: Icons.schedule_rounded, value: '~${stats['estimatedDaysToNextReward']}d', label: 'Next Reward', iconColor: Colors.blue.shade100),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEnhancedMiniStat({required IconData icon, required String value, required String label, required Color iconColor}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: iconColor.withOpacity(0.9)),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.8))),
      ],
    );
  }

  Widget _buildEnhancedCategoryFilter() {
    final categories = [
      {'value': 'all', 'label': 'All', 'icon': Icons.all_inclusive_rounded, 'color': Get.theme.colorScheme.primary},
      {'value': 'discount', 'label': 'Discounts', 'icon': Icons.discount_rounded, 'color': Colors.green.shade600},
      {'value': 'service', 'label': 'Services', 'icon': Icons.medical_services_rounded, 'color': Colors.blue.shade600},
      {'value': 'premium', 'label': 'Premium', 'icon': Icons.diamond_rounded, 'color': Colors.purple.shade600},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Obx(() {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  final isSelected = rewardCtrl.selectedCategory == category['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? category['color'] as Color : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? category['color'] as Color : Colors.grey.shade300, width: isSelected ? 0 : 1.5),
                        boxShadow: isSelected
                            ? [BoxShadow(color: (category['color'] as Color).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                            : [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => rewardCtrl.setCategory(category['value'] as String),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Row(
                              children: [
                                Icon(category['icon'] as IconData, size: 18, color: isSelected ? Colors.white : category['color'] as Color),
                                const SizedBox(width: 8),
                                Text(
                                  category['label'] as String,
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEnhancedRewardCard(Reward reward) {
    final daysLeft = reward.daysUntilExpiry;
    final isLimited = reward.isLimited && reward.remainingQuantity > 0;
    final canRedeem = rewardCtrl.pointsBalance.availablePoints >= reward.pointsRequired;
    return InkWell(
      onTap: canRedeem && reward.isAvailable ? () => _showRedeemConfirmation(reward) : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 15, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_getCategoryColor(reward.category), _getCategoryColor(reward.category).withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${reward.pointsRequired}',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                          child: Icon(_getCategoryIcon(reward.category), size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        if (isLimited)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              '${reward.remainingQuantity} left',
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.orange.shade700, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.title,
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          reward.description,
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (daysLeft > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: daysLeft < 7 ? Colors.red.shade50 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: daysLeft < 7 ? Colors.red.shade200 : Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.timer_rounded, size: 12, color: daysLeft < 7 ? Colors.red.shade600 : Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${daysLeft}d',
                                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: daysLeft < 7 ? Colors.red.shade600 : Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                            Text(
                              '${reward.pointsRequired} points',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: _getCategoryColor(reward.category)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 42,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: canRedeem ? _getCategoryColor(reward.category) : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: canRedeem ? [BoxShadow(color: _getCategoryColor(reward.category).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
                          ),
                          child: Center(
                            child: Text(
                              canRedeem ? 'Redeem Now' : 'Need ${reward.pointsRequired - rewardCtrl.pointsBalance.availablePoints} more',
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: canRedeem ? Colors.white : Colors.grey.shade600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await rewardCtrl.loadRewards();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildEnhancedHistoryFilter(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                final stats = rewardCtrl.getRewardStats();
                return Row(
                  children: [
                    Expanded(
                      child: _buildEnhancedStatCard(
                        icon: Icons.receipt_long_rounded,
                        value: '${stats['totalTransactions']}',
                        label: 'Total',
                        color: Colors.blue.shade50,
                        iconColor: Colors.blue.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildEnhancedStatCard(icon: Icons.check_circle_rounded, value: '${stats['usedRewards']}', label: 'Used', color: Colors.green.shade50, iconColor: Colors.green.shade600),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildEnhancedStatCard(
                        icon: Icons.pending_rounded,
                        value: '${stats['pendingRewards']}',
                        label: 'Pending',
                        color: Colors.orange.shade50,
                        iconColor: Colors.orange.shade600,
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                if (rewardCtrl.isLoading) {
                  return _buildShimmerList();
                }
                final transactions = rewardCtrl.filteredTransactions;
                if (rewardCtrl.filteredTransactions.isEmpty) {
                  return _buildEmptyHistoryState();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: transactions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return _buildEnhancedTransactionCard(transaction);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedHistoryFilter() {
    final filters = [
      {'value': 'all', 'label': 'All', 'icon': Icons.all_inclusive_rounded, 'color': Get.theme.colorScheme.primary},
      {'value': 'pending', 'label': 'Pending', 'icon': Icons.pending_rounded, 'color': Colors.orange.shade600},
      {'value': 'completed', 'label': 'Used', 'icon': Icons.check_circle_rounded, 'color': Colors.green.shade600},
      {'value': 'expired', 'label': 'Expired', 'icon': Icons.timer_off_rounded, 'color': Colors.red.shade600},
      {'value': 'cancelled', 'label': 'Cancelled', 'icon': Icons.cancel_rounded, 'color': Colors.grey.shade600},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Filter by Status',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: filters.map((filter) {
                final isSelected = rewardCtrl.selectedFilter == filter['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? filter['color'] as Color : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? filter['color'] as Color : Colors.grey.shade300, width: isSelected ? 0 : 1.5),
                      boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => rewardCtrl.setFilter(filter['value'].toString()),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            children: [
                              Icon(filter['icon'] as IconData, size: 16, color: isSelected ? Colors.white : filter['color'] as Color),
                              const SizedBox(width: 8),
                              Text(
                                filter['label'] as String,
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEnhancedStatCard({required IconData icon, required String value, required String label, required Color color, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildEnhancedTransactionCard(RewardTransaction transaction) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    transaction.rewardTitle,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: _getStatusColor(transaction.status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    _getStatusText(transaction.status),
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _getStatusColor(transaction.status)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTransactionDetail(icon: Icons.star_rounded, text: '${transaction.pointsUsed} points', color: Colors.amber.shade600),
                const SizedBox(width: 16),
                _buildTransactionDetail(icon: Icons.calendar_month_rounded, text: DateFormat('MMM dd, yyyy').format(transaction.redeemedAt), color: Colors.grey.shade600),
              ],
            ),
            if (transaction.redemptionCode != null && transaction.redemptionCode!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildTransactionDetail(icon: Icons.qr_code_rounded, text: 'Code: ${transaction.redemptionCode}', color: Colors.green.shade600),
              ),
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  transaction.notes.toString(),
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (transaction.status == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => rewardCtrl.markAsUsed(transaction.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade50,
                          foregroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Mark as Used', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showCancelConfirmation(transaction),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Cancel', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionDetail({required IconData icon, required String text, required Color color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 120,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyRewardsState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(color: Get.theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.card_giftcard_rounded, size: 50, color: Get.theme.colorScheme.primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            'No Rewards Available',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new exciting rewards',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(color: Get.theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.history_rounded, size: 50, color: Get.theme.colorScheme.primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            'No Reward History',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            'Redeem your first reward to see history',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showRedeemConfirmation(Reward reward) {
    Get.dialog(
      AlertDialog(
        title: Text('Redeem Reward', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to redeem:', style: GoogleFonts.poppins()),
            const SizedBox(height: 12),
            Text(
              reward.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Get.theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                const SizedBox(width: 4),
                Text('${reward.pointsRequired} points', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              ],
            ),
            if (reward.daysUntilExpiry > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: Colors.orange.shade600),
                    const SizedBox(width: 4),
                    Text('Expires in ${reward.daysUntilExpiry} days', style: GoogleFonts.poppins(color: Colors.orange.shade700)),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.close(1), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.close(1);
              final success = await rewardCtrl.redeemReward(reward);
              if (success) {}
            },
            style: ElevatedButton.styleFrom(backgroundColor: Get.theme.colorScheme.primary),
            child: const Text('Confirm Redeem'),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(RewardTransaction transaction) {
    Get.dialog(
      AlertDialog(
        title: Text('Cancel Redemption', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to cancel this reward redemption?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Get.close(1), child: const Text('No')),
          ElevatedButton(
            onPressed: () {
              Get.close(1);
              rewardCtrl.cancelTransaction(transaction.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Used';
      case 'pending':
        return 'Pending';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'discount':
        return Colors.green.shade600;
      case 'service':
        return Colors.blue.shade600;
      case 'premium':
        return Colors.purple.shade600;
      default:
        return Get.theme.colorScheme.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'discount':
        return Icons.discount_rounded;
      case 'service':
        return Icons.medical_services_rounded;
      case 'premium':
        return Icons.diamond_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'expired':
        return Colors.red.shade600;
      case 'cancelled':
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
