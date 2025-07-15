import 'package:flutter/material.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_loading.dart';

class RankingAchievementShimmer extends StatelessWidget {
  const RankingAchievementShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ShimmerBox(
                width: 150,
                height: 20,
                borderRadius: 4,
              ),
              const ShimmerBox(
                width: 100,
                height: 36,
                borderRadius: 8,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Month filter
          Container(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 12,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: const ShimmerBox(
                  width: 70,
                  height: 25,
                  borderRadius: 25,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Top 3 Section shimmer (taller)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2196F3),
                  const Color(0xFF1976D2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Rank 2 (Left)
                _buildTop3ItemShimmer(false),
                // Rank 1 (Center) - Larger
                _buildTop3ItemShimmer(true),
                // Rank 3 (Right)
                _buildTop3ItemShimmer(false),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Regular list section shimmer with header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header shimmer
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ShimmerBox(
                        width: 120,
                        height: 16,
                        borderRadius: 4,
                      ),
                      const ShimmerBox(
                        width: 80,
                        height: 28,
                        borderRadius: 14,
                      ),
                    ],
                  ),
                ),
                // List items shimmer (collapsed by default)
                Container(
                  height: 0,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: 3,
                    itemBuilder: (context, index) =>
                        _buildRegularRankingItemShimmer(index + 4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTop3ItemShimmer(bool isCenter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          // Medal badge shimmer (taller)
          Container(
            width: isCenter ? 70 : 60,
            height: isCenter ? 70 : 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: Center(
              child: ShimmerBox(
                width: isCenter ? 35 : 30,
                height: isCenter ? 35 : 30,
                borderRadius: isCenter ? 17 : 15,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Name shimmer
          ShimmerBox(
            width: isCenter ? 80 : 60,
            height: 14,
            borderRadius: 7,
          ),
          const SizedBox(height: 4),
          // Rayon name shimmer (smaller)
          ShimmerBox(
            width: isCenter ? 60 : 50,
            height: 11,
            borderRadius: 5,
          ),
          const SizedBox(height: 6),
          // Score shimmer
          ShimmerBox(
            width: isCenter ? 50 : 40,
            height: 16,
            borderRadius: 8,
          ),
          const SizedBox(height: 12),
          // Bar chart shimmer (taller)
          Container(
            width: isCenter ? 50 : 40,
            height: isCenter ? 60 : 50,
            child: Column(
              children: [
                // Bar chart visualization shimmer (taller)
                Expanded(
                  flex: 2,
                  child: ShimmerBox(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 6,
                  ),
                ),
                const SizedBox(height: 4),
                // Rank number shimmer
                ShimmerBox(
                  width: isCenter ? 20 : 16,
                  height: 16,
                  borderRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularRankingItemShimmer(int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rank number
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: ShimmerBox(
                width: 20,
                height: 20,
                borderRadius: 10,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(
                  width: 120,
                  height: 16,
                  borderRadius: 4,
                ),
                const SizedBox(height: 4),
                const ShimmerBox(
                  width: 80,
                  height: 12,
                  borderRadius: 4,
                ),
              ],
            ),
          ),

          // Achievement percentage
          const ShimmerBox(
            width: 60,
            height: 20,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}
