import 'package:flutter/material.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_loading.dart';

class ShimmerApprovalLoading extends StatelessWidget {
  const ShimmerApprovalLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const ShimmerBox(
              width: 180,
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

            // Filter chips
            Row(
              children: [
                for (int i = 0; i < 3; i++) ...[
                  ShimmerBox(
                    width: 80 + (i * 20),
                    height: 36,
                    borderRadius: 18,
                    margin: const EdgeInsets.only(right: 8),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // Approval items
            for (int i = 0; i < 5; i++) ...[
              _buildApprovalItem(),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalItem() {
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
                width: 140,
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

          // Requester info
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
                      width: 120,
                      height: 16,
                      borderRadius: 4,
                    ),
                    SizedBox(height: 8),
                    ShimmerBox(
                      width: 180,
                      height: 14,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Schedule details
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

          // Buttons
          Row(
            children: [
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: 40,
                  borderRadius: 8,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: 40,
                  borderRadius: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
