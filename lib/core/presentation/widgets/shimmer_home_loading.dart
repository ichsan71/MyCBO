import 'package:flutter/material.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_loading.dart';

class ShimmerHomeLoading extends StatelessWidget {
  const ShimmerHomeLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome text
            ShimmerBox(
              width: 180,
              height: 24,
              borderRadius: 4,
            ),
            const SizedBox(height: 8),
            ShimmerBox(
              width: 220,
              height: 30,
              borderRadius: 4,
            ),
            const SizedBox(height: 40),

            // Grid of menu items
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: List.generate(
                  8,
                  (index) => _buildMenuCardShimmer(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCardShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerBox(
            width: 64,
            height: 64,
            borderRadius: 32,
          ),
          const SizedBox(height: 16),
          ShimmerBox(
            width: 80,
            height: 16,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}
