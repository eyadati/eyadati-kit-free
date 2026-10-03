import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class DottedDivider extends StatelessWidget {
  final Color? color;
  final double spacing;

  const DottedDivider({
    super.key,
    this.color,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        20,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: spacing / 2),
            height: 2,
            decoration: BoxDecoration(
              color: color ?? AppColors.border,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}

class VerticalDottedDivider extends StatelessWidget {
  final Color? color;
  final double spacing;

  const VerticalDottedDivider({
    super.key,
    this.color,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        15,
        (index) => Container(
          margin: EdgeInsets.symmetric(vertical: spacing / 2),
          width: 2,
          height: 2,
          decoration: BoxDecoration(
            color: color ?? AppColors.border,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}