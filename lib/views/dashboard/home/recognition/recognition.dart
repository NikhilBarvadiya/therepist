import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/views/dashboard/home/recognition/recognition_ctrl.dart';
import 'package:therepist/views/dashboard/home/recognition/ui/recognition_card.dart';
import 'package:therepist/views/dashboard/home/recognition/ui/recognition_shimmer.dart';

class RecognitionScreen extends StatelessWidget {
  const RecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RecognitionCtrl ctrl = Get.put(RecognitionCtrl());
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            toolbarHeight: 70,
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
            title: Text('Recognitions', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),

          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: Obx(() {
              if (ctrl.isLoading && ctrl.recognitions.isEmpty) {
                return SliverToBoxAdapter(child: RecognitionShimmer(showList: true, itemCount: 3));
              }
              final recognitions = ctrl.recognitions;
              if (recognitions.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(Icons.card_giftcard_rounded, size: 50, color: decoration.colorScheme.primary.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Recognitions',
                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Text('No recognitions found', style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == recognitions.length) {
                    return ctrl.hasMore
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: ctrl.isLoadingMore ? const CircularProgressIndicator() : TextButton(onPressed: () => ctrl.loadRecognitions(), child: const Text('Load More')),
                            ),
                          )
                        : const SizedBox();
                  }
                  final recognition = recognitions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RecognitionCard(recognition: recognition),
                  );
                }, childCount: recognitions.length + (ctrl.hasMore ? 1 : 0)),
              );
            }),
          ),
        ],
      ),
    );
  }
}
