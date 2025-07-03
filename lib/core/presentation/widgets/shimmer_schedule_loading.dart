import 'package:flutter/material.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_loading.dart';

class ShimmerScheduleLoading extends StatelessWidget {
  const ShimmerScheduleLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            const ShimmerContainer(
              height: 24,
              width: 200,
            ),
            const SizedBox(height: 24),

            // Schedule items shimmer
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ShimmerContainer(
                              width: 40,
                              height: 40,
                              borderRadius: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShimmerContainer(
                                    width: 150,
                                    height: 16,
                                  ),
                                  SizedBox(height: 8),
                                  ShimmerContainer(
                                    width: 100,
                                    height: 14,
                                  ),
                                ],
                              ),
                            ),
                            ShimmerContainer(
                              width: 60,
                              height: 24,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ShimmerContainer(
                          height: 14,
                          width: double.infinity,
                        ),
                        SizedBox(height: 8),
                        ShimmerContainer(
                          height: 14,
                          width: 200,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
