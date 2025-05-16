import 'package:flutter/material.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_loading.dart';

class ShimmerScheduleDetailLoading extends StatelessWidget {
  const ShimmerScheduleDetailLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(
                  width: 150,
                  height: 28,
                  borderRadius: 4,
                ),
                ShimmerBox(
                  width: 100,
                  height: 32,
                  borderRadius: 16,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(
                    width: 120,
                    height: 20,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: Colors.white,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 12),

                  // Status details
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(
                            width: 100,
                            height: 16,
                            borderRadius: 4,
                          ),
                          SizedBox(height: 4),
                          ShimmerBox(
                            width: 80,
                            height: 16,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                      ShimmerBox(
                        width: 80,
                        height: 32,
                        borderRadius: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(
                    width: 140,
                    height: 20,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: Colors.white,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 12),

                  // Info rows
                  for (int i = 0; i < 5; i++) ...[
                    const Row(
                      children: [
                        ShimmerBox(
                          width: 24,
                          height: 24,
                          borderRadius: 12,
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox(
                              width: 80,
                              height: 14,
                              borderRadius: 4,
                            ),
                            SizedBox(height: 4),
                            ShimmerBox(
                              width: 200,
                              height: 16,
                              borderRadius: 4,
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (i < 4) const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Products card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(
                    width: 100,
                    height: 20,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: Colors.white,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 12),

                  // Products
                  for (int i = 0; i < 3; i++) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: const Row(
                        children: [
                          ShimmerBox(
                            width: 40,
                            height: 40,
                            borderRadius: 20,
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
                                SizedBox(height: 4),
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
                    ),
                    if (i < 2) const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            const Row(
              children: [
                Expanded(
                  child: ShimmerBox(
                    width: double.infinity,
                    height: 48,
                    borderRadius: 8,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ShimmerBox(
                    width: double.infinity,
                    height: 48,
                    borderRadius: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
