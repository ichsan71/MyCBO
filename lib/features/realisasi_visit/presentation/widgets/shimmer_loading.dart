import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/presentation/theme/app_theme.dart';

class ShimmerRealisasiVisitCard extends StatelessWidget {
  const ShimmerRealisasiVisitCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.borderRadiusMedium,
      ),
      elevation: 2,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              _buildShimmerRow(),
              const SizedBox(height: 8),
              _buildShimmerRow(),
              const SizedBox(height: 8),
              _buildShimmerRow(),
              const SizedBox(height: 8),
              _buildShimmerRow(),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildShimmerStatusIndicator(),
                  const SizedBox(width: 16),
                  _buildShimmerStatusIndicator(),
                  const SizedBox(width: 16),
                  _buildShimmerStatusIndicator(),
                ],
              ),
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
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 120,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerStatusIndicator() {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
