import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:therepist/utils/toaster.dart';
import '../../../../models/service_model.dart';
import '../../../auth/auth_service.dart';

class MultiSelectBottomSheet extends StatefulWidget {
  final String title;
  final String itemType;
  final List<ServiceModel> selectedItems;
  final Function(List<ServiceModel>) onSelectionChanged;

  const MultiSelectBottomSheet({super.key, required this.title, required this.itemType, required this.selectedItems, required this.onSelectionChanged});

  @override
  State<MultiSelectBottomSheet> createState() => _MultiSelectBottomSheetState();
}

class _MultiSelectBottomSheetState extends State<MultiSelectBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ServiceModel> _tempSelected = [], _filteredItems = [];
  final List<ServiceModel> _items = [];

  int _page = 1;
  bool _isLoading = false, _hasNextPage = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedItems);
    _filteredItems = [];
    _fetchItems();
    _searchController.addListener(_filterItems);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && !_isLoading && _hasNextPage) {
        _fetchItems();
      }
    });
  }

  Future<void> _fetchItems() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final authService = Get.find<AuthService>();
      final response = widget.itemType == 'services' ? await authService.getServices(page: _page, search: _searchQuery) : await authService.getEquipment(page: _page, search: _searchQuery);
      if (response == null) return;
      final List<ServiceModel> newItems = (response['docs'] as List).map((e) => ServiceModel.fromJson(e)).toList();
      setState(() {
        _items.addAll(newItems);
        _filteredItems = _searchController.text.isEmpty ? List.from(_items) : _items.where((item) => item.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
        _hasNextPage = response['hasNextPage'] ?? false;
        _page++;
      });
    } catch (e) {
      toaster.error('Error: ${e.toString()}');
    } finally {
      _isLoading = false;
    }
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredItems = List.from(_items);
      } else {
        _filteredItems = _items.where((item) => item.name.toLowerCase().contains(query)).toList();
      }
    });
    if (query.isNotEmpty && query != _searchQuery) {
      _page = 1;
      _hasNextPage = true;
      _fetchItems();
    }
  }

  void _toggleSelection(ServiceModel item) {
    setState(() {
      if (_tempSelected.contains(item)) {
        _tempSelected.remove(item);
      } else {
        _tempSelected.add(item);
      }
    });
  }

  void _confirmSelection() {
    widget.onSelectionChanged(_tempSelected);
    Navigator.pop(context);
  }

  void _clearSelection() {
    setState(() {
      _tempSelected.clear();
    });
  }

  String _getChargeDisplay(ServiceModel item) {
    if (item.charge != null && item.charge! > 0) {
      return '₹${item.charge!.toStringAsFixed(0)}';
    } else if (item.lowCharge != null && item.highCharge != null && item.lowCharge! > 0 && item.highCharge! > 0) {
      return '₹${item.lowCharge!.toStringAsFixed(0)} - ₹${item.highCharge!.toStringAsFixed(0)}';
    } else {
      return 'Price on request';
    }
  }

  Color _getChargeColor(ServiceModel item) {
    if (item.charge != null && item.charge! > 0) {
      if (item.charge! < 500) {
        return const Color(0xFF10B981);
      } else if (item.charge! < 2000) {
        return const Color(0xFFF59E0B);
      } else {
        return const Color(0xFFEF4444);
      }
    }
    return const Color(0xFF6B7280);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchField(),
            _buildSelectionInfo(),
            Expanded(child: _buildListView()),
            _buildFooterButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
            ),
          ),
          if (_tempSelected.isNotEmpty) ...[
            TextButton(
              onPressed: _clearSelection,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
              child: Text(
                'Clear',
                style: TextStyle(fontSize: 14, color: const Color(0xFFEF4444), fontWeight: FontWeight.w500),
              ),
            ),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Text(
              '${_tempSelected.length}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search ${widget.itemType}...',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6B7280), size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF6B7280)),
                    onPressed: () {
                      _searchController.clear();
                      _filterItems();
                    },
                  )
                : null,
            hintStyle: const TextStyle(color: Color(0xFF6B7280)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionInfo() {
    if (_tempSelected.isEmpty) return const SizedBox();
    final totalCharges = _tempSelected.fold<double>(0, (sum, item) {
      return sum + (item.charge ?? item.lowCharge ?? 0).toDouble();
    });
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_money_rounded, size: 16, color: const Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_tempSelected.length} item${_tempSelected.length > 1 ? 's' : ''} selected',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF065F46)),
                        ),
                        if (totalCharges > 0) Text('Estimated total: ₹${totalCharges.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Color(0xFF047857))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    if (_filteredItems.isEmpty) {
      if (_isLoading) {
        return const Center(
          child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()),
        );
      }
      if (!_isLoading) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 64, color: const Color(0xFF9CA3AF)),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty ? 'No ${widget.itemType} available' : 'No results found',
                style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isEmpty ? 'Check back later for new ${widget.itemType}' : 'Try searching with different keywords',
                style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _filteredItems.length + (_isLoading ? 1 : 0) + (_hasNextPage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredItems.length) {
          if (_isLoading) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()),
            );
          }
          if (_hasNextPage) {
            return const SizedBox();
          }
          return const SizedBox();
        }
        if (_filteredItems.isEmpty) return const SizedBox();
        final item = _filteredItems[index];
        final isSelected = _tempSelected.contains(item);
        return _buildListItem(item, isSelected);
      },
    );
  }

  Widget _buildListItem(ServiceModel item, bool isSelected) {
    final chargeDisplay = _getChargeDisplay(item);
    final chargeColor = _getChargeColor(item);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF10B981).withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB), width: isSelected ? 1.5 : 1),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: isSelected ? const Color(0xFF10B981) : const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(8)),
          child: Icon(item.icon ?? Icons.category_rounded, color: isSelected ? Colors.white : const Color(0xFF10B981), size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111827)),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: chargeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: chargeColor.withOpacity(0.3)),
              ),
              child: Text(
                chargeDisplay,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: chargeColor),
              ),
            ),
          ],
        ),
        subtitle: item.charge != null && item.lowCharge != null && item.highCharge != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    if (item.lowCharge != null && item.highCharge != null && item.lowCharge! > 0 && item.highCharge! > 0)
                      Text('Range: ₹${item.lowCharge!} - ₹${item.highCharge!}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                  ],
                ),
              )
            : null,
        trailing: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isSelected ? const Color(0xFF10B981) : const Color(0xFFD1D5DB)),
          ),
          child: isSelected ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
        ),
        onTap: () => _toggleSelection(item),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE5E7EB), width: 1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _tempSelected.isEmpty ? null : _confirmSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: _tempSelected.isEmpty ? const Color(0xFFE5E7EB) : const Color(0xFF10B981),
                foregroundColor: _tempSelected.isEmpty ? const Color(0xFF9CA3AF) : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Confirm',
                    style: TextStyle(fontWeight: FontWeight.w600, color: _tempSelected.isEmpty ? const Color(0xFF9CA3AF) : Colors.white),
                  ),
                  if (_tempSelected.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        '${_tempSelected.length}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
