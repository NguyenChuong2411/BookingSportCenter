import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Custom map pin widget matching the design with sport-specific colors
class MapPinWidget extends StatelessWidget {
  final String sportType;
  final bool isSelected;
  final VoidCallback? onTap;

  const MapPinWidget({
    super.key,
    required this.sportType,
    this.isSelected = false,
    this.onTap,
  });

  /// Get color based on sport type
  Color get _getPinColor {
    switch (sportType.toLowerCase()) {
      case 'football':
      case 'soccer':
        return const Color(0xFF00FF00); // Green
      case 'basketball':
        return const Color(0xFFFF6600); // Orange
      case 'tennis':
        return const Color(0xFF7CB342); // Light green
      case 'volleyball':
        return const Color(0xFFFFFFFF); // White
      case 'badminton':
        return const Color(0xFFFFEB3B); // Yellow
      default:
        return AppColors.primaryGreen;
    }
  }

  /// Get icon based on sport type
  IconData get _getSportIcon {
    switch (sportType.toLowerCase()) {
      case 'football':
      case 'soccer':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'tennis':
        return Icons.sports_tennis;
      case 'volleyball':
        return Icons.sports_volleyball;
      case 'badminton':
        return Icons.sports_tennis; // Flutter doesn't have badminton icon
      default:
        return Icons.sports_soccer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Pin shadow
          Positioned(
            top: 34,
            child: Container(
              width: 20,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),

          // Pin body (teardrop shape)
          CustomPaint(
            size: const Size(40, 50),
            painter: _PinPainter(color: _getPinColor, isSelected: isSelected),
          ),

          // Sport icon circle
          Positioned(
            top: 4,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getPinColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _getSportIcon,
                color: sportType.toLowerCase() == 'volleyball'
                    ? Colors.grey[700]
                    : Colors.white,
                size: 18,
              ),
            ),
          ),

          // Selection indicator (if selected)
          if (isSelected)
            Positioned(
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom painter for pin teardrop shape
class _PinPainter extends CustomPainter {
  final Color color;
  final bool isSelected;

  _PinPainter({required this.color, this.isSelected = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path();

    // Create teardrop/pin shape
    const double circleCenterY = 20;
    const double circleRadius = 18;
    const double bottomTipY = 46;

    // Draw shadow path first
    final shadowPath = Path();
    shadowPath.addOval(
      Rect.fromCircle(
        center: Offset(size.width / 2 + 1, circleCenterY + 1),
        radius: circleRadius,
      ),
    );
    shadowPath.moveTo(size.width / 2 + 1, circleCenterY + circleRadius);
    shadowPath.quadraticBezierTo(
      size.width / 2 + 8,
      bottomTipY - 5,
      size.width / 2 + 1,
      bottomTipY + 1,
    );
    shadowPath.quadraticBezierTo(
      size.width / 2 - 6,
      bottomTipY - 5,
      size.width / 2 + 1,
      circleCenterY + circleRadius,
    );
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw main white pin body
    path.addOval(
      Rect.fromCircle(
        center: Offset(size.width / 2, circleCenterY),
        radius: circleRadius,
      ),
    );

    // Add pointed bottom
    path.moveTo(size.width / 2, circleCenterY + circleRadius);
    path.quadraticBezierTo(
      size.width / 2 + 8,
      bottomTipY - 5,
      size.width / 2,
      bottomTipY,
    );
    path.quadraticBezierTo(
      size.width / 2 - 8,
      bottomTipY - 5,
      size.width / 2,
      circleCenterY + circleRadius,
    );

    canvas.drawPath(path, paint);

    // Draw border if selected
    if (isSelected) {
      final borderPaint = Paint()
        ..color = AppColors.primaryBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_PinPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isSelected != isSelected;
}
