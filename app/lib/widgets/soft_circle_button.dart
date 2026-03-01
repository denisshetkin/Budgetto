import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SoftCircleButton extends StatelessWidget {
  const SoftCircleButton({
    super.key,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(36),
      onTap: onTap,
      child: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          color: AppColors.surface1,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.stroke, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3D000000),
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
