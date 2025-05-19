import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerApprovalCard extends StatelessWidget {
  const ShimmerApprovalCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 200,
                          height: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildShimmerRow(),
              const SizedBox(height: 8),
              _buildShimmerRow(),
              const SizedBox(height: 8),
              _buildShimmerRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerRow() {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        Container(
          width: 150,
          height: 16,
          color: Colors.white,
        ),
      ],
    );
  }
}

// Alias untuk ShimmerApprovalCard
class ShimmerLoading extends ShimmerApprovalCard {
  const ShimmerLoading({Key? key}) : super(key: key);
}
