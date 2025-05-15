import 'package:flutter/material.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_loading.dart';

class ShimmerScheduleLoading extends StatelessWidget {
  const ShimmerScheduleLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Header - Informasi Jadwal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      ShimmerBox(width: 24, height: 24, borderRadius: 4),
                      const SizedBox(width: 12),
                      ShimmerBox(width: 160, height: 24, borderRadius: 4),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.white,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  
                  // Form Fields
                  _buildFormField(),
                  const SizedBox(height: 20),
                  _buildFormField(),
                  const SizedBox(height: 20),
                  _buildFormField(),
                  const SizedBox(height: 20),
                  _buildFormField(),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Dokter Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      ShimmerBox(width: 24, height: 24, borderRadius: 4),
                      const SizedBox(width: 12),
                      ShimmerBox(width: 100, height: 24, borderRadius: 4),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.white,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Field
                  ShimmerBox(
                    width: double.infinity,
                    height: 48,
                    borderRadius: 12,
                  ),
                  const SizedBox(height: 16),
                  
                  // Doctor List
                  for (int i = 0; i < 5; i++) ...[
                    ShimmerListTile(
                      height: 70,
                      hasTrailing: true,
                      subtitleLines: 1,
                    ),
                    if (i < 4) const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Products Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      ShimmerBox(width: 24, height: 24, borderRadius: 4),
                      const SizedBox(width: 12),
                      ShimmerBox(width: 120, height: 24, borderRadius: 4),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.white,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Field
                  ShimmerBox(
                    width: double.infinity,
                    height: 48, 
                    borderRadius: 12,
                  ),
                  const SizedBox(height: 16),
                  
                  // Product List
                  for (int i = 0; i < 5; i++) ...[
                    ShimmerListTile(
                      hasTrailing: true,
                      subtitleLines: 1,
                    ),
                    if (i < 4) const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Notes Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      ShimmerBox(width: 24, height: 24, borderRadius: 4),
                      const SizedBox(width: 12),
                      ShimmerBox(width: 80, height: 24, borderRadius: 4),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.white,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  
                  // Note Field
                  ShimmerBox(
                    width: double.infinity,
                    height: 100,
                    borderRadius: 12,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            ShimmerBox(
              width: double.infinity,
              height: 56,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(width: 100, height: 16, borderRadius: 4),
        const SizedBox(height: 8),
        ShimmerBox(
          width: double.infinity,
          height: 48,
          borderRadius: 8,
        ),
      ],
    );
  }
} 