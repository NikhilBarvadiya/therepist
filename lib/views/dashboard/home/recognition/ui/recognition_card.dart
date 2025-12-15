import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:therepist/models/recognition_model.dart';
import 'package:therepist/utils/decoration.dart';
import 'package:therepist/utils/network/api_config.dart';
import 'package:therepist/views/dashboard/home/recognition/ui/recognition_details.dart';

class RecognitionCard extends StatelessWidget {
  final Recognition recognition;
  final bool isCompact;
  final VoidCallback? onTap;

  const RecognitionCard({super.key, required this.recognition, this.isCompact = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return isCompact ? _buildCompactCard(context) : _buildFullCard(context);
  }

  Widget _buildFullCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            onTap ??
            () {
              Get.to(() => RecognitionDetails(recognition: recognition), transition: Transition.rightToLeft);
            },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageSection(context),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          recognition.title,
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: recognition.statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          recognition.statusText,
                          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: recognition.statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recognition.description,
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  _buildDoctorInfo(),
                  const SizedBox(height: 12),
                  _buildValidityInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            onTap ??
            () {
              Get.to(() => RecognitionDetails(recognition: recognition), transition: Transition.rightToLeft);
            },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(color: Colors.grey.shade200),
              child: recognition.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _getImageUrl(recognition.images.first),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey.shade200),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 40),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 40),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recognition.title,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recognition.description,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: recognition.statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        recognition.statusText,
                        style: GoogleFonts.poppins(fontSize: 11, color: recognition.statusColor, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    if (recognition.images.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 60)),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(color: Colors.grey.shade200),
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: _getImageUrl(recognition.images.first),
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade200),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 60),
              ),
            ),
          ),
          if (recognition.images.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.photo_library_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '+${recognition.images.length - 1}',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.4), Colors.transparent]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: recognition.doctorProfileImage != null && recognition.doctorProfileImage!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(imageUrl: _getImageUrl(recognition.doctorProfileImage!), fit: BoxFit.cover),
                  )
                : Icon(Icons.person_rounded, color: decoration.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recognition.doctorName.isNotEmpty ? recognition.doctorName : 'Unknown Doctor',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (recognition.doctorClinicName.isNotEmpty)
                  Text(
                    recognition.doctorClinicName,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidityInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildValidityItem(icon: Icons.calendar_today_rounded, label: 'Start Date', value: recognition.formattedStartDate),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildValidityItem(icon: Icons.event_available_rounded, label: 'End Date', value: recognition.formattedEndDate),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildValidityItem(icon: Icons.timer_rounded, label: 'Duration', value: '${recognition.durationDays} days'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildValidityItem(
                  icon: Icons.update_rounded,
                  label: 'Days Left',
                  value: recognition.isExpired ? 'Expired' : '${recognition.daysRemaining}',
                  valueColor: recognition.isExpired
                      ? Colors.red.shade600
                      : recognition.daysRemaining <= 7
                      ? Colors.orange.shade600
                      : Colors.green.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValidityItem({required IconData icon, required String label, required String value, Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.blue.shade600),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? Colors.black87),
        ),
      ],
    );
  }

  String _getImageUrl(String imagePath) {
    return APIConfig.resourceBaseURL + imagePath;
  }
}
