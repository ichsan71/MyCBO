import 'package:flutter/material.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_loading.dart';

class ShimmerScheduleListLoading extends StatelessWidget {
  const ShimmerScheduleListLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title area
            const ShimmerBox(
              width: 200,
              height: 28,
              borderRadius: 4,
            ),
            const SizedBox(height: 8),
            const ShimmerBox(
              width: 250,
              height: 16,
              borderRadius: 4,
            ),
            const SizedBox(height: 24),

            // Filter/search area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 48,
                      borderRadius: 8,
                    ),
                  ),
                  SizedBox(width: 12),
                  ShimmerBox(
                    width: 48,
                    height: 48,
                    borderRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Schedule items
            for (int i = 0; i < 6; i++) ...[
              _buildScheduleItem(),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(
                width: 120,
                height: 20,
                borderRadius: 4,
              ),
              ShimmerBox(
                width: 80,
                height: 20,
                borderRadius: 4,
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(color: Colors.white, height: 1),
          SizedBox(height: 12),

          // Doctor info
          Row(
            children: [
              ShimmerBox(
                width: 48,
                height: 48,
                borderRadius: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                      width: 150,
                      height: 16,
                      borderRadius: 4,
                    ),
                    SizedBox(height: 6),
                    ShimmerBox(
                      width: 100,
                      height: 14,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Location
          Row(
            children: [
              ShimmerBox(
                width: 20,
                height: 20,
                borderRadius: 4,
              ),
              SizedBox(width: 8),
              ShimmerBox(
                width: 200,
                height: 16,
                borderRadius: 4,
              ),
            ],
          ),
          SizedBox(height: 8),

          // Status
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ShimmerBox(
                width: 80,
                height: 28,
                borderRadius: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
