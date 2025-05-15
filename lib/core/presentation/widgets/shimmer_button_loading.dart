import 'package:flutter/material.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_loading.dart';

class ShimmerButtonLoading extends StatelessWidget {
  final Color? baseColor;
  final Color? highlightColor;
  final double height;
  final double width;

  const ShimmerButtonLoading({
    Key? key,
    this.baseColor,
    this.highlightColor,
    this.height = 24,
    this.width = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ShimmerLoading(
      baseColor: baseColor ?? Colors.white.withOpacity(0.3),
      highlightColor: highlightColor ?? Colors.white.withOpacity(0.8),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
