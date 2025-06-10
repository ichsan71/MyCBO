import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class KPIChart extends StatelessWidget {
  final double achievement;
  final double weight;
  final double result;
  final Color achievementColor;
  final Color weightColor;
  final Color resultColor;

  const KPIChart({
    Key? key,
    required this.achievement,
    required this.weight,
    required this.result,
    this.achievementColor = const Color(0xFF00B2FF),
    this.weightColor = const Color(0xFFFFB800),
    this.resultColor = const Color(0xFFFF4081),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: CustomPaint(
            painter: KPIChartPainter(
              achievement: achievement,
              weight: weight,
              result: result,
              achievementColor: achievementColor,
              weightColor: weightColor,
              resultColor: resultColor,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem(
                'Achievement', '${achievement.toInt()}%', achievementColor),
            _buildLegendItem('Weight', '${weight.toInt()}', weightColor),
            _buildLegendItem('Result', '${result.toInt()}', resultColor),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class KPIChartPainter extends CustomPainter {
  final double achievement;
  final double weight;
  final double result;
  final Color achievementColor;
  final Color weightColor;
  final Color resultColor;

  KPIChartPainter({
    required this.achievement,
    required this.weight,
    required this.result,
    required this.achievementColor,
    required this.weightColor,
    required this.resultColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const startAngle = -math.pi / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15.0;

    // Draw background circles
    paint.color = Colors.grey[200]!;
    canvas.drawCircle(center, radius * 0.9, paint);
    canvas.drawCircle(center, radius * 0.7, paint);
    canvas.drawCircle(center, radius * 0.5, paint);

    // Draw achievement arc
    paint.color = achievementColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.9),
      startAngle,
      2 * math.pi * (achievement / 100),
      false,
      paint,
    );

    // Draw weight arc
    paint.color = weightColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.7),
      startAngle,
      2 * math.pi * (weight / 100),
      false,
      paint,
    );

    // Draw result arc
    paint.color = resultColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.5),
      startAngle,
      2 * math.pi * (result / 100),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
