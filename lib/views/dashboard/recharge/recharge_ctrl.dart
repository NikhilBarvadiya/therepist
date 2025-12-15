import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:therepist/models/recharge_model.dart';
import 'package:therepist/utils/toaster.dart';
import 'package:therepist/views/auth/auth_service.dart';

class RechargeCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final RxList<RechargePlan> _rechargePlans = <RechargePlan>[].obs;
  final RxList<DoctorRechargePayment> _transactions = <DoctorRechargePayment>[].obs;
  final Rx<WalletSummary> _walletSummary = WalletSummary(totalBalance: 0.0, totalEarned: 0.0, totalSpent: 0.0, availableBalance: 0.0, lastUpdated: DateTime.now()).obs;

  final RxString selectedFilter = 'all'.obs;
  RechargePlan? selectedRechargePlan;
  final RxBool _isLoading = false.obs, _isLoadingPlans = false.obs, _isLoadingTransactions = false.obs;
  final RxBool _isLoadingMore = false.obs, _hasMore = true.obs;
  final RxInt _currentPage = 1.obs;

  List<RechargePlan> get rechargePlans => _rechargePlans;

  List<DoctorRechargePayment> get transactions => _transactions;

  WalletSummary get walletSummary => _walletSummary.value;

  bool get isLoading => _isLoading.value;

  bool get isLoadingPlans => _isLoadingPlans.value;

  bool get isLoadingTransactions => _isLoadingTransactions.value;

  bool get isLoadingMore => _isLoadingMore.value;

  bool get hasMore => _hasMore.value;

  late Razorpay razorpay;

  @override
  void onInit() {
    super.onInit();
    _initializeRazorpay();
    loadInitialData();
  }

  @override
  void onClose() {
    razorpay.clear();
    super.onClose();
  }

  void _initializeRazorpay() {
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void initiatePayment({required RechargePlan plan}) {
    selectedRechargePlan = plan;
    _isLoading.value = true;
    final options = {
      'key': 'rzp_test_RHRLTvT4Rm3WOP',
      'currency': 'INR',
      'amount': (plan.amount * 100).toInt(),
      'name': 'Recharge Plan',
      'description': 'Promote your recharge for ${plan.validityDays.toInt()} days',
      'retry': {'enabled': true, 'max_count': 2},
      'send_sms_hash': true,
      'theme': {'color': '#F57C00'},
      'external': {
        'wallets': ['paytm'],
      },
    };
    try {
      razorpay.open(options);
    } catch (e) {
      toaster.error('Failed to initiate payment: $e');
      _isLoading.value = false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      if (selectedRechargePlan == null) return;
      await createRecharge(
        paymentMethod: "online",
        transactionId: response.paymentId.toString(),
        rechargePlanId: selectedRechargePlan!.id,
        extraDetails: {
          'paymentMethod': 'razorpay',
          'amount': (selectedRechargePlan!.amount / 100).toDouble().toStringAsFixed(2),
          'currency': 'INR',
          'status': 'completed',
          'transactionId': response.paymentId ?? '',
          'orderId': response.orderId ?? '',
          'data': {'transactionId': response.paymentId ?? '', 'paymentDate': DateTime.now().toIso8601String()},
          'extraDetails': {},
          'refundDetails': {'refundAmount': 0, 'refundReason': '', 'refundDate': null, 'refundTransactionId': ''},
        },
      );
    } catch (e) {
      toaster.error('Payment processing error: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _isLoading.value = false;
    toaster.error('Payment failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    toaster.info('External wallet selected: ${response.walletName}');
  }

  Future<void> loadInitialData() async {
    try {
      await Future.wait([loadRechargePlans(), loadWalletTransactions(reset: true)]);
      _updateWalletSummary();
    } catch (e) {
      toaster.error('Failed to load data: $e');
    }
  }

  Future<void> loadRechargePlans() async {
    _isLoadingPlans.value = true;
    try {
      final plans = await _authService.getRechargePlans();
      _rechargePlans.assignAll(plans);
    } catch (e) {
      toaster.error('Failed to load recharge plans: $e');
      rethrow;
    } finally {
      _isLoadingPlans.value = false;
    }
  }

  Future<void> loadWalletTransactions({bool reset = false}) async {
    if (reset) {
      _currentPage.value = 1;
      _hasMore.value = true;
      _isLoadingTransactions.value = true;
      _transactions.clear();
    } else if (!_hasMore.value) {
      return;
    } else {
      _isLoadingMore.value = true;
    }
    try {
      final response = await _authService.getWalletTransactions(page: _currentPage.value, limit: 10, status: selectedFilter.value != 'all' ? selectedFilter.value : null);
      if (response != null && response['docs'] is List) {
        final List newTransactions = response['docs'];
        if (newTransactions.isNotEmpty) {
          final parsedTransactions = newTransactions.map((item) => DoctorRechargePayment.fromJson(item)).toList();
          if (reset) {
            _transactions.assignAll(parsedTransactions);
          } else {
            _transactions.addAll(parsedTransactions);
          }
          final totalPages = response['totalPages'] ?? 1;
          final currentPageNum = response['page'] ?? _currentPage.value;
          _hasMore.value = currentPageNum < totalPages;
          if (_hasMore.value) {
            _currentPage.value = currentPageNum + 1;
          }
        } else {
          _hasMore.value = false;
        }
      } else {
        if (!_isLoadingMore.value) {
          toaster.warning('No transactions found');
        }
        _hasMore.value = false;
      }
      _updateWalletSummary();
    } catch (e) {
      toaster.error('Failed to load transactions: $e');
    } finally {
      if (reset) {
        _isLoadingTransactions.value = false;
      }
      _isLoadingMore.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadInitialData();
  }

  Future<void> setFilter(String filter) async {
    selectedFilter.value = filter;
    await loadWalletTransactions(reset: true);
  }

  void _updateWalletSummary() {
    _walletSummary.value = WalletSummary.fromPayments(_transactions);
  }

  Future<DoctorRechargePayment?> createRecharge({required String rechargePlanId, required String paymentMethod, required String transactionId, Map<String, dynamic>? extraDetails}) async {
    try {
      _isLoading.value = true;
      final request = CreateRechargeRequest(rechargePlanId: rechargePlanId, paymentMethod: paymentMethod, transactionId: transactionId, extraDetails: extraDetails);
      final payment = await _authService.createRechargePayment(request);
      _transactions.insert(0, payment);
      _updateWalletSummary();
      toaster.success('Recharge successful! ₹${payment.amount} added to your wallet.');
      return payment;
    } catch (e) {
      toaster.error('Failed to complete recharge: $e');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      case 'refund':
        return 'Refunded';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      case 'refund':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      case 'refund':
        return Icons.refresh;
      default:
        return Icons.info;
    }
  }

  String getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'card':
        return '💳';
      case 'upi':
        return '📱';
      case 'wallet':
        return '👛';
      case 'net-banking':
        return '🏦';
      default:
        return '💰';
    }
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  String truncateText(String text, {int maxLength = 20}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
