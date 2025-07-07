import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/presentation/theme/app_theme.dart';

class KpiChartShimmer extends StatelessWidget {
  const KpiChartShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Pie Chart Section Shimmer
        SizedBox(
          height: 220,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      Shimmer.fromColors(
                        baseColor:
                            isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        highlightColor:
                            isDark ? Colors.grey[700]! : Colors.grey[100]!,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Shimmer.fromColors(
                              baseColor: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[300]!,
                              highlightColor: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[100]!,
                              child: Container(
                                width: 60,
                                height: 14,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Shimmer.fromColors(
                              baseColor: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[300]!,
                              highlightColor: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[100]!,
                              child: Container(
                                width: 80,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.width * 0.4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      5,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Shimmer.fromColors(
                              baseColor: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[300]!,
                              highlightColor: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[100]!,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Shimmer.fromColors(
                                baseColor: isDark
                                    ? Colors.grey[800]!
                                    : Colors.grey[300]!,
                                highlightColor: isDark
                                    ? Colors.grey[700]!
                                    : Colors.grey[100]!,
                                child: Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // KPI Cards Grid Shimmer
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Shimmer.fromColors(
                        baseColor:
                            isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        highlightColor:
                            isDark ? Colors.grey[700]! : Colors.grey[100]!,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Shimmer.fromColors(
                          baseColor:
                              isDark ? Colors.grey[800]! : Colors.grey[300]!,
                          highlightColor:
                              isDark ? Colors.grey[700]! : Colors.grey[100]!,
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor:
                            isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        highlightColor:
                            isDark ? Colors.grey[700]! : Colors.grey[100]!,
                        child: Container(
                          width: 35,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Shimmer.fromColors(
                        baseColor:
                            isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        highlightColor:
                            isDark ? Colors.grey[700]! : Colors.grey[100]!,
                        child: Container(
                          width: 60,
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Shimmer.fromColors(
                        baseColor:
                            isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        highlightColor:
                            isDark ? Colors.grey[700]! : Colors.grey[100]!,
                        child: Container(
                          width: 45,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Shimmer.fromColors(
                        baseColor:
                            isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        highlightColor:
                            isDark ? Colors.grey[700]! : Colors.grey[100]!,
                        child: Container(
                          width: 40,
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Shimmer.fromColors(
                    baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                    highlightColor:
                        isDark ? Colors.grey[700]! : Colors.grey[100]!,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
