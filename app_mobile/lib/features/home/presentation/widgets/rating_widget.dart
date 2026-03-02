import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final double size;
  final int maxStars;

  const RatingWidget({
    super.key,
    required this.rating,
    this.size = 16,
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: AppColors.starYellow, size: size);
        } else if (index < rating) {
          return Icon(Icons.star_half, color: AppColors.starYellow, size: size);
        } else {
          return Icon(
            Icons.star_border,
            color: AppColors.starYellow,
            size: size,
          );
        }
      }),
    );
  }
}
