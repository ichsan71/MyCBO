import 'package:flutter/material.dart';

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    Key? key,
    required this.child,
    this.isLoading = true,
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          stops: const [
            0.0,
            0.5,
            1.0,
          ],
          begin: const Alignment(-1.0, -0.3),
          end: const Alignment(1.0, 0.3),
          tileMode: TileMode.clamp,
        ).createShader(bounds);
      },
      child: widget.child,
    );
  }
}

class ShimmerContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerContainer({
    Key? key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// Widget untuk menampilkan kotak shimmer
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// Widget untuk menampilkan baris dengan shimmer
class ShimmerListTile extends StatelessWidget {
  final double height;
  final bool hasLeading;
  final bool hasTrailing;
  final int titleLines;
  final int subtitleLines;
  final double lineHeight;
  final double? leadingSize;
  final EdgeInsetsGeometry padding;

  const ShimmerListTile({
    Key? key,
    this.height = 80.0,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.titleLines = 1,
    this.subtitleLines = 1,
    this.lineHeight = 14.0,
    this.leadingSize = 48.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasLeading) ...[
            ShimmerBox(
              width: leadingSize!,
              height: leadingSize!,
              borderRadius: leadingSize! / 2, // Circular
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                for (int i = 0; i < titleLines; i++) ...[
                  if (i > 0) const SizedBox(height: 4),
                  ShimmerBox(
                    width: i == 0 ? double.infinity : 160,
                    height: lineHeight,
                  ),
                ],
                if (subtitleLines > 0) const SizedBox(height: 8),
                // Subtitle
                for (int i = 0; i < subtitleLines; i++) ...[
                  if (i > 0) const SizedBox(height: 4),
                  ShimmerBox(
                    width: 100 +
                        (60 * i.toDouble()), // Varies width for visual effect
                    height: lineHeight - 2,
                  ),
                ],
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: 8),
            const ShimmerBox(
              width: 24,
              height: 24,
            ),
          ],
        ],
      ),
    );
  }
}

// Widget untuk menampilkan formulir dengan shimmer
class ShimmerForm extends StatelessWidget {
  final int fieldCount;
  final double fieldHeight;
  final EdgeInsetsGeometry padding;
  final bool hasLabels;
  final double space;

  const ShimmerForm({
    Key? key,
    this.fieldCount = 4,
    this.fieldHeight = 56.0,
    this.padding = const EdgeInsets.all(16.0),
    this.hasLabels = true,
    this.space = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(fieldCount, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: space),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasLabels) ...[
                  const ShimmerBox(
                    width: 120,
                    height: 16,
                  ),
                  const SizedBox(height: 8),
                ],
                ShimmerBox(
                  width: double.infinity,
                  height: fieldHeight,
                  borderRadius: 12,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
