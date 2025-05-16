import 'package:flutter/material.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_loading.dart';

class ShimmerFormLoading extends StatelessWidget {
  final bool isDetailed;
  final bool hasImage;
  
  const ShimmerFormLoading({
    Key? key, 
    this.isDetailed = true,
    this.hasImage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const ShimmerBox(
              width: 200,
              height: 24,
              borderRadius: 4,
            ),
            const SizedBox(height: 24),
            
            if (hasImage) ...[
              // Image placeholder
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ShimmerBox(
                      width: 150,
                      height: 40,
                      borderRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Form fields
            for (int i = 0; i < (isDetailed ? 5 : 3); i++) ...[
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    width: 120,
                    height: 16,
                    borderRadius: 4,
                  ),
                  SizedBox(height: 8),
                  ShimmerBox(
                    width: double.infinity,
                    height: 48,
                    borderRadius: 8,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Additional section for detailed form
            if (isDetailed) ...[
              const ShimmerBox(
                width: 160,
                height: 20,
                borderRadius: 4,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              
              for (int i = 0; i < 2; i++) ...[
                const Row(
                  children: [
                    ShimmerBox(
                      width: 24,
                      height: 24,
                      borderRadius: 4,
                    ),
                    SizedBox(width: 12),
                    ShimmerBox(
                      width: 200,
                      height: 16,
                      borderRadius: 4,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ],
            
            // Submit button
            const SizedBox(height: 16),
            const ShimmerBox(
              width: double.infinity,
              height: 48,
              borderRadius: 24,
            ),
          ],
        ),
      ),
    );
  }
} 