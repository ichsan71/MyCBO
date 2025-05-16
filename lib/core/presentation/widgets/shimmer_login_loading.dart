import 'package:flutter/material.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_loading.dart';

class ShimmerLoginLoading extends StatelessWidget {
  const ShimmerLoginLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo placeholder
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 40),

          // Input fields
          Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                // Username field
                ShimmerBox(
                  width: double.infinity,
                  height: 50,
                  borderRadius: 8,
                ),
                SizedBox(height: 20),

                // Password field
                ShimmerBox(
                  width: double.infinity,
                  height: 50,
                  borderRadius: 8,
                ),
                SizedBox(height: 30),

                // Login button
                ShimmerBox(
                  width: double.infinity,
                  height: 50,
                  borderRadius: 25,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
