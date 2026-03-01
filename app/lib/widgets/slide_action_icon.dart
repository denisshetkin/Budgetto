import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SlideActionIcon extends StatelessWidget {
  const SlideActionIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 30,
    this.containerSize = 52,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double containerSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: containerSize,
      width: containerSize,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.stroke),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: size),
    );
  }
}
