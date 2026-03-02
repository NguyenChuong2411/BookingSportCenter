import 'package:flutter/material.dart';
import '../../domain/entities/court.dart';
import '../../../../core/constants/app_colors.dart';
import 'rating_widget.dart';

class CourtCard extends StatelessWidget {
  final Court court;
  final VoidCallback? onBookNow;

  const CourtCard({super.key, required this.court, this.onBookNow});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Court Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.backgroundGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.sports_soccer,
                color: AppColors.textSecondary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),

            // Court Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    court.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    court.address,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  RatingWidget(rating: court.rating, size: 12),
                ],
              ),
            ),

            // Book Now Button
            ElevatedButton(
              onPressed: onBookNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBlue,
                foregroundColor: AppColors.textWhite,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Book now',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
