import 'package:get/get.dart';
import 'package:therepist/models/reward_model.dart';
import 'package:therepist/utils/toaster.dart';

class RewardCtrl extends GetxController {
  static RewardCtrl get to => Get.find();

  final RxList<Reward> _availableRewards = <Reward>[].obs;
  final RxList<RewardTransaction> _transactions = <RewardTransaction>[].obs;
  final Rx<PointsBalance> _pointsBalance = PointsBalance(totalPoints: 0, earnedPoints: 0, spentPoints: 0, availablePoints: 2500, lastUpdated: DateTime.now()).obs;

  final RxString _selectedFilter = 'all'.obs;
  final RxString _selectedCategory = 'all'.obs;
  final RxBool _isLoading = false.obs;

  List<Reward> get availableRewards => _availableRewards.where((reward) => reward.isAvailable).toList();

  List<RewardTransaction> get transactions => _transactions;

  PointsBalance get pointsBalance => _pointsBalance.value;

  String get selectedFilter => _selectedFilter.value;

  String get selectedCategory => _selectedCategory.value;

  bool get isLoading => _isLoading.value;

  List<RewardTransaction> get filteredTransactions {
    List<RewardTransaction> result = _transactions;

    if (_selectedFilter.value != 'all') {
      result = result.where((t) => t.status == _selectedFilter.value).toList();
    }

    return result;
  }

  List<Reward> get filteredRewards {
    List<Reward> result = availableRewards;

    if (_selectedCategory.value != 'all') {
      result = result.where((r) => r.category == _selectedCategory.value).toList();
    }

    // Sort by points required (ascending)
    result.sort((a, b) => a.pointsRequired.compareTo(b.pointsRequired));

    return result;
  }

  @override
  void onInit() {
    super.onInit();
    loadRewards();
  }

  Future<void> loadRewards() async {
    _isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      await _addSampleRewards();
      await _addSampleTransactions();
      await _calculatePointsBalance();
    } catch (e) {
      toaster.error('Failed to load rewards: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _calculatePointsBalance() async {
    final earned = _transactions.where((t) => t.status == 'completed').fold(0, (sum, t) => sum + t.pointsUsed);

    final spent = _transactions.where((t) => t.status != 'cancelled').fold(0, (sum, t) => sum + t.pointsUsed);

    final total = earned + 2500; // Base points

    _pointsBalance.value = PointsBalance(totalPoints: total, earnedPoints: earned, spentPoints: spent, availablePoints: total - spent, lastUpdated: DateTime.now());
  }

  Future<void> setFilter(String filter) async {
    _selectedFilter.value = filter;
    update();
  }

  Future<void> setCategory(String category) async {
    _selectedCategory.value = category;
  }

  Future<bool> redeemReward(Reward reward) async {
    if (!reward.isAvailable) {
      toaster.error('This reward is no longer available');
      return false;
    }

    if (_pointsBalance.value.availablePoints < reward.pointsRequired) {
      toaster.error('Insufficient points');
      return false;
    }

    // Generate redemption code
    final redemptionCode = 'REW${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    final transaction = RewardTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      rewardId: reward.id,
      rewardTitle: reward.title,
      pointsUsed: reward.pointsRequired,
      redeemedAt: DateTime.now(),
      status: 'pending',
      redemptionCode: redemptionCode,
      notes: 'Reward redeemed - pending verification',
    );

    _transactions.insert(0, transaction);

    // Update reward quantity if limited
    if (reward.isLimited) {
      final index = _availableRewards.indexWhere((r) => r.id == reward.id);
      if (index != -1) {
        final updatedReward = Reward(
          id: reward.id,
          title: reward.title,
          description: reward.description,
          pointsRequired: reward.pointsRequired,
          imageUrl: reward.imageUrl,
          category: reward.category,
          expiryDate: reward.expiryDate,
          createdAt: reward.createdAt,
          redemptionCode: reward.redemptionCode,
          isLimited: reward.isLimited,
          remainingQuantity: reward.remainingQuantity - 1,
          isActive: reward.isActive,
        );
        _availableRewards[index] = updatedReward;
      }
    }
    await _calculatePointsBalance();
    toaster.success('🎉 Reward redeemed successfully!');
    toaster.info('Your redemption code: $redemptionCode');
    return true;
  }

  Future<void> markAsUsed(String transactionId) async {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      final transaction = _transactions[index];
      _transactions[index] = RewardTransaction(
        id: transaction.id,
        rewardId: transaction.rewardId,
        rewardTitle: transaction.rewardTitle,
        pointsUsed: transaction.pointsUsed,
        redeemedAt: transaction.redeemedAt,
        status: 'completed',
        redemptionCode: transaction.redemptionCode,
        notes: transaction.notes,
        usedAt: DateTime.now(),
      );
      toaster.success('Reward marked as used');
    }
  }

  Future<void> cancelTransaction(String transactionId) async {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      final transaction = _transactions[index];
      if (transaction.status == 'pending') {
        _pointsBalance.value = PointsBalance(
          totalPoints: _pointsBalance.value.totalPoints,
          earnedPoints: _pointsBalance.value.earnedPoints,
          spentPoints: _pointsBalance.value.spentPoints - transaction.pointsUsed,
          availablePoints: _pointsBalance.value.availablePoints + transaction.pointsUsed,
          lastUpdated: DateTime.now(),
        );
      }
      _transactions[index] = RewardTransaction(
        id: transaction.id,
        rewardId: transaction.rewardId,
        rewardTitle: transaction.rewardTitle,
        pointsUsed: transaction.pointsUsed,
        redeemedAt: transaction.redeemedAt,
        status: 'cancelled',
        redemptionCode: transaction.redemptionCode,
        notes: 'Transaction cancelled by user',
        usedAt: transaction.usedAt,
      );
      toaster.info('Transaction cancelled');
    }
  }

  Map<String, dynamic> getRewardStats() {
    final totalRewards = availableRewards.length;
    final totalTransactions = _transactions.length;
    final usedRewards = _transactions.where((t) => t.status == 'completed').length;
    final pendingRewards = _transactions.where((t) => t.status == 'pending').length;
    final expiredRewards = _transactions.where((t) => t.status == 'expired').length;

    final pointsEarned = _pointsBalance.value.earnedPoints;
    final pointsSpent = _pointsBalance.value.spentPoints;
    const pointsPerDay = 10;
    final estimatedDaysToNextReward = availableRewards.isNotEmpty ? (availableRewards.first.pointsRequired / pointsPerDay).ceil() : 0;

    return {
      'totalRewards': totalRewards,
      'totalTransactions': totalTransactions,
      'usedRewards': usedRewards,
      'pendingRewards': pendingRewards,
      'expiredRewards': expiredRewards,
      'pointsEarned': pointsEarned,
      'pointsSpent': pointsSpent,
      'estimatedDaysToNextReward': estimatedDaysToNextReward,
    };
  }

  Future<void> addPoints(int points, String source) async {
    _pointsBalance.value = PointsBalance(
      totalPoints: _pointsBalance.value.totalPoints + points,
      earnedPoints: _pointsBalance.value.earnedPoints + points,
      spentPoints: _pointsBalance.value.spentPoints,
      availablePoints: _pointsBalance.value.availablePoints + points,
      lastUpdated: DateTime.now(),
    );
    toaster.success('+$points points added from $source');
  }

  Future<void> _addSampleRewards() async {
    final sampleRewards = [
      Reward(
        id: 'reward_1',
        title: '10% Doctor Consultation Discount',
        description: 'Get 10% off on your next consultation with any doctor',
        pointsRequired: 200,
        category: 'discount',
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        redemptionCode: 'DOC10',
        isLimited: true,
        remainingQuantity: 25,
      ),
      Reward(
        id: 'reward_2',
        title: 'Free Basic Health Checkup',
        description: 'Complimentary basic health checkup package',
        pointsRequired: 500,
        category: 'service',
        expiryDate: DateTime.now().add(const Duration(days: 60)),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        isLimited: true,
        remainingQuantity: 15,
      ),
      Reward(
        id: 'reward_3',
        title: 'Medicine Discount Voucher',
        description: '15% off on all medicines from pharmacy',
        pointsRequired: 300,
        category: 'discount',
        expiryDate: DateTime.now().add(const Duration(days: 45)),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        redemptionCode: 'MED15',
        isLimited: false,
      ),
      Reward(
        id: 'reward_4',
        title: 'Premium Health Insights Report',
        description: 'Detailed health analysis and personalized recommendations',
        pointsRequired: 400,
        category: 'premium',
        expiryDate: DateTime.now().add(const Duration(days: 90)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isLimited: true,
        remainingQuantity: 20,
      ),
      Reward(
        id: 'reward_5',
        title: 'Emergency Contact Priority',
        description: 'Priority access to emergency helpline',
        pointsRequired: 1500,
        category: 'service',
        expiryDate: DateTime.now().add(const Duration(days: 180)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isLimited: true,
        remainingQuantity: 10,
      ),
      Reward(
        id: 'reward_6',
        title: 'Nutrition Consultation',
        description: 'Free consultation with nutrition expert',
        pointsRequired: 800,
        category: 'service',
        expiryDate: DateTime.now().add(const Duration(days: 90)),
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        isLimited: true,
        remainingQuantity: 8,
      ),
    ];
    _availableRewards.assignAll(sampleRewards);
  }

  Future<void> _addSampleTransactions() async {
    final sampleTransactions = [
      RewardTransaction(
        id: 'trans_1',
        rewardId: 'reward_3',
        rewardTitle: 'Medicine Discount Voucher',
        pointsUsed: 300,
        redeemedAt: DateTime.now().subtract(const Duration(days: 5)),
        status: 'completed',
        redemptionCode: 'MED15',
        notes: 'Used at pharmacy',
        usedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      RewardTransaction(
        id: 'trans_2',
        rewardId: 'reward_1',
        rewardTitle: '10% Doctor Consultation Discount',
        pointsUsed: 200,
        redeemedAt: DateTime.now().subtract(const Duration(days: 2)),
        status: 'pending',
        redemptionCode: 'DOC10',
        notes: 'Pending doctor appointment',
      ),
      RewardTransaction(
        id: 'trans_3',
        rewardId: 'reward_4',
        rewardTitle: 'Premium Health Insights Report',
        pointsUsed: 400,
        redeemedAt: DateTime.now().subtract(const Duration(days: 15)),
        status: 'completed',
        notes: 'Report received and reviewed',
        usedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      RewardTransaction(
        id: 'trans_4',
        rewardId: 'reward_2',
        rewardTitle: 'Free Basic Health Checkup',
        pointsUsed: 500,
        redeemedAt: DateTime.now().subtract(const Duration(days: 30)),
        status: 'expired',
        notes: 'Expired before use',
      ),
    ];

    _transactions.assignAll(sampleTransactions);
    await _calculatePointsBalance();
  }

  Future<void> clearAllData() async {
    _availableRewards.clear();
    _transactions.clear();
    update();
  }
}
