import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:therepist/models/recharge_model.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/views/dashboard/recharge/recharge_ctrl.dart';

class Recharge extends StatefulWidget {
  const Recharge({super.key});

  @override
  State<Recharge> createState() => _RechargeState();
}

class _RechargeState extends State<Recharge> with SingleTickerProviderStateMixin {
  final RechargeCtrl rechargeCtrl = Get.put(RechargeCtrl());
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  final List<String> _tabTitles = ['Recharge Plans', 'Transaction History'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (rechargeCtrl.hasMore && !rechargeCtrl.isLoadingMore) {
        rechargeCtrl.loadWalletTransactions();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: decoration.colorScheme.primary,
              pinned: true,
              floating: true,
              leading: IconButton(
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
                  backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
                ),
                icon: Icon(Icons.arrow_back, color: decoration.colorScheme.primary),
                onPressed: () => Get.close(1),
              ),
              title: Text(
                'Wallet & Recharge',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    onTap: (a) => setState(() {}),
                    tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
                    labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                    unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
                    labelColor: decoration.colorScheme.primary,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
                    indicator: BoxDecoration(borderRadius: BorderRadius.circular(12), color: decoration.colorScheme.primary.withOpacity(0.1)),
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                ),
              ),
            ),
            if (_tabController.index == 0) SliverToBoxAdapter(child: _buildWalletOverviewCard()),
          ];
        },
        body: Obx(() {
          return TabBarView(
            controller: _tabController,
            children: [
              if (rechargeCtrl.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: decoration.colorScheme.primary),
                          const SizedBox(height: 16),
                          Text(
                            'Processing Payment...',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (!rechargeCtrl.isLoading) ...[_buildRechargePlansTab(), _buildTransactionsTab()],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildWalletOverviewCard() {
    return Obx(() {
      final summary = rechargeCtrl.walletSummary;
      if (rechargeCtrl.isLoading) {
        return SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
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
                          'Available Balance',
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${summary.availableBalance.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white, height: 0.9),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                'Wallet',
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 30),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(height: 1, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(icon: Icons.arrow_upward_rounded, value: '₹${summary.totalEarned.toStringAsFixed(2)}', label: 'Total Earned', color: Colors.green.shade100),
                    _buildStatItem(icon: Icons.arrow_downward_rounded, value: '₹${summary.totalSpent.toStringAsFixed(2)}', label: 'Total Spent', color: Colors.red.shade100),
                    _buildStatItem(icon: Icons.update_rounded, value: DateFormat('MMM dd, yyyy').format(summary.lastUpdated), label: 'Last Updated', color: Colors.blue.shade100),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white.withOpacity(0.8))),
      ],
    );
  }

  Widget _buildRechargePlansTab() {
    return RefreshIndicator(
      onRefresh: () async => await rechargeCtrl.loadRechargePlans(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose a Plan',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text('Select a plan to recharge your wallet', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ),
          Obx(() {
            if (rechargeCtrl.isLoadingPlans && rechargeCtrl.rechargePlans.isEmpty) {
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildPlanShimmer()), childCount: 3),
                ),
              );
            }
            final plans = rechargeCtrl.rechargePlans;
            if (plans.isEmpty) {
              return SliverFillRemaining(
                child: _buildEmptyState(icon: Icons.account_balance_wallet_rounded, title: 'No Recharge Plans', message: 'Plans will be available soon'),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final plan = plans[index];
                  return Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildRechargePlanCard(plan));
                }, childCount: plans.length),
              ),
            );
          }),
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    final filters = [
      {'value': 'all', 'label': 'All'},
      {'value': 'paid', 'label': 'Paid'},
      {'value': 'pending', 'label': 'Pending'},
      {'value': 'cancelled', 'label': 'Cancelled'},
      {'value': 'refund', 'label': 'Refund'},
    ];
    return RefreshIndicator(
      onRefresh: () async => await rechargeCtrl.loadWalletTransactions(reset: true),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return Obx(() {
                      final filter = filters[index];
                      final isSelected = rechargeCtrl.selectedFilter.value == filter['value'];
                      return FilterChip(
                        selected: isSelected,
                        onSelected: (_) => rechargeCtrl.setFilter(filter['value']!),
                        label: Text(filter['label']!, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                        selectedColor: rechargeCtrl.getStatusColor(filter['value']!),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                        ),
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                        checkmarkColor: Colors.white,
                      );
                    });
                  },
                ),
              ),
            ),
          ),
          Obx(() {
            if (rechargeCtrl.isLoadingTransactions && rechargeCtrl.transactions.isEmpty) {
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildTransactionShimmer()), childCount: 5),
                ),
              );
            }
            final transactions = rechargeCtrl.transactions;
            if (transactions.isEmpty) {
              return SliverFillRemaining(
                child: _buildEmptyState(
                  icon: Icons.history_rounded,
                  title: 'No Transactions',
                  message: rechargeCtrl.selectedFilter.value == 'all' ? 'Complete your first recharge to see history' : 'No ${rechargeCtrl.selectedFilter} transactions found',
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == transactions.length) {
                    return rechargeCtrl.hasMore
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: rechargeCtrl.isLoadingMore
                                  ? const CircularProgressIndicator()
                                  : TextButton(onPressed: () => rechargeCtrl.loadWalletTransactions(), child: const Text('Load More')),
                            ),
                          )
                        : const SizedBox();
                  }
                  final transaction = transactions[index];
                  return Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildTransactionCard(transaction));
                }, childCount: transactions.length + (rechargeCtrl.hasMore ? 1 : 0)),
              ),
            );
          }),
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  Widget _buildRechargePlanCard(RechargePlan plan) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => rechargeCtrl.initiatePayment(plan: plan),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.account_balance_wallet_rounded, color: decoration.colorScheme.primary, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title.capitalizeFirst.toString(),
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.description.capitalizeFirst.toString(),
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: Text(
                            '${plan.validityDays} days',
                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.green.shade700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (plan.amount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Text(
                              '₹${plan.amount.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.blue.shade700),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: decoration.colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  'BUY',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(DoctorRechargePayment transaction) {
    DateTime now = DateTime.now();
    DateTime startDate = DateTime.parse(transaction.activationStart.toString()).toLocal();
    bool isAdvance = startDate.isAfter(now);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.planSnapshot.title,
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Plan: ${transaction.planSnapshot.validityDays} ${transaction.planSnapshot.validityDays == 1 ? 'day' : 'days'}',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: rechargeCtrl.getStatusColor(transaction.status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(rechargeCtrl.getStatusIcon(transaction.status), size: 14, color: rechargeCtrl.getStatusColor(transaction.status)),
                      const SizedBox(width: 4),
                      Text(
                        rechargeCtrl.getStatusText(transaction.status),
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: rechargeCtrl.getStatusColor(transaction.status)),
                      ),
                    ],
                  ),
                ),
                if (isAdvance)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(rechargeCtrl.getStatusIcon("Advance"), size: 14, color: rechargeCtrl.getStatusColor("Advance")),
                        const SizedBox(width: 4),
                        Text(
                          rechargeCtrl.getStatusText("Advance"),
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: rechargeCtrl.getStatusColor("Advance")),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Text(rechargeCtrl.getPaymentMethodIcon(transaction.paymentMethod), style: const TextStyle(fontSize: 14)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.paymentMethod.toUpperCase(),
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                      ),
                      Text('ID: ${transaction.transactionId.substring(0, 8)}...', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Text(
                  '₹${transaction.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: decoration.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment_rounded, size: 14, color: Colors.grey.shade700),
                      const SizedBox(width: 6),
                      Text(
                        'Validity Details',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    spacing: 10.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildValidityItem(
                          label: 'Purchase Date',
                          value: DateFormat('dd MMM, hh:mm a').format(DateTime.parse(transaction.activationStart.toString()).toLocal()),
                          icon: Icons.shopping_cart_rounded,
                        ),
                      ),
                      Expanded(
                        child: _buildValidityItem(
                          label: 'Last Date',
                          value: DateFormat('dd MMM, hh:mm a').format(DateTime.parse(transaction.activationEnd.toString()).toLocal()),
                          icon: Icons.event_available_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (transaction.extraDetails.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.payment_rounded, size: 14, color: Colors.grey.shade700),
                        const SizedBox(width: 6),
                        Text(
                          'Payment Details',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (transaction.extraDetails['walletCredited'] == true) _buildDetailItem(icon: Icons.check_circle, text: 'Wallet credited successfully', color: Colors.green.shade600),
                    if (transaction.extraDetails['payment_gateway'] != null)
                      _buildDetailItem(icon: Icons.credit_card_rounded, text: 'Gateway: ${transaction.extraDetails['payment_gateway']}', color: Colors.grey.shade600),
                    if (transaction.extraDetails['currency'] != null)
                      _buildDetailItem(icon: Icons.currency_rupee_rounded, text: 'Currency: ${transaction.extraDetails['currency']}', color: Colors.grey.shade600),
                    if (transaction.extraDetails['walletCreditedAt'] != null)
                      _buildDetailItem(
                        icon: Icons.access_time_rounded,
                        text: 'Credited: ${DateFormat('dd MMM, hh:mm a').format(DateTime.parse(transaction.extraDetails['walletCreditedAt']))}',
                        color: Colors.grey.shade600,
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildValidityItem({required String label, required String value, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade600),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600)),
            Text(
              value,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem({required IconData icon, required String text, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: GoogleFonts.poppins(fontSize: 11, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 16, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Container(width: double.infinity, height: 12, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 24,
                          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 80,
                          height: 24,
                          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 60,
                height: 32,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 150, height: 16, color: Colors.grey.shade300),
                        const SizedBox(height: 6),
                        Container(width: 100, height: 12, color: Colors.grey.shade300),
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 28,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 80, height: 14, color: Colors.grey.shade300),
                        const SizedBox(height: 4),
                        Container(width: 100, height: 12, color: Colors.grey.shade300),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(width: 80, height: 18, color: Colors.grey.shade300),
                      const SizedBox(height: 4),
                      Container(width: 60, height: 12, color: Colors.grey.shade300),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 50, color: decoration.colorScheme.primary.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
