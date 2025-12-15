import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:therepist/models/recognition_model.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/utils/network/api_config.dart';

class RecognitionDetails extends StatelessWidget {
  final Recognition recognition;

  const RecognitionDetails({super.key, required this.recognition});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(background: _buildImageCarousel(), collapseMode: CollapseMode.pin),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              onPressed: () => Get.close(1),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          recognition.title,
                          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black87),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: recognition.statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          recognition.statusText,
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: recognition.statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(recognition.description, style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey.shade800, height: 1.5)),
                  const SizedBox(height: 24),
                  _buildDoctorInfoCard(),
                  const SizedBox(height: 24),
                  _buildValidityCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    if (recognition.images.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 80)),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        CarouselSlider.builder(
          itemCount: recognition.images.length,
          options: CarouselOptions(
            height: 300,
            viewportFraction: 1.0,
            autoPlay: recognition.images.length > 1,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: recognition.images.length > 1,
          ),
          itemBuilder: (context, index, realIndex) {
            return CachedNetworkImage(
              imageUrl: _getImageUrl(recognition.images[index]),
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade200),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 60),
              ),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.3), Colors.transparent]),
          ),
        ),
        if (recognition.images.length > 1)
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
              child: Text(
                '${recognition.images.length} images',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDoctorInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: recognition.doctorProfileImage != null && recognition.doctorProfileImage!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(imageUrl: _getImageUrl(recognition.doctorProfileImage!), fit: BoxFit.cover),
                    )
                  : Icon(Icons.person_rounded, color: decoration.colorScheme.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Awarded To', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text(
                    recognition.doctorName.isNotEmpty ? recognition.doctorName : 'Unknown Doctor',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                  if (recognition.doctorClinicName.isNotEmpty) Text(recognition.doctorClinicName, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Validity Period',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(icon: Icons.calendar_today_rounded, title: 'Start Date', value: recognition.formattedStartDate),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailItem(icon: Icons.event_available_rounded, title: 'End Date', value: recognition.formattedEndDate),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(icon: Icons.timer_rounded, title: 'Duration', value: '${recognition.durationDays} days'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailItem(icon: Icons.update_rounded, title: 'Status', value: recognition.statusText, valueColor: recognition.statusColor),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (recognition.daysRemaining > 0 && !recognition.isExpired)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_rounded, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recognition.daysRemaining <= 7 ? 'Expires in ${recognition.daysRemaining} days' : 'Valid for ${recognition.daysRemaining} more days',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.blue.shade700),
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

  Widget _buildDetailItem({required IconData icon, required String title, required String value, Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: valueColor ?? Colors.black87),
        ),
      ],
    );
  }

  String _getImageUrl(String imagePath) {
    return APIConfig.resourceBaseURL + imagePath;
  }
}
