import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RevenueChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const RevenueChart({
    super.key,
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Performance',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live AdSense',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _LineChartPainter(
                    values: values,
                    labels: labels,
                    primaryColor: primaryColor,
                    textColor: isDark ? Colors.white54 : Colors.black45,
                    gridColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color primaryColor;
  final Color textColor;
  final Color gridColor;

  _LineChartPainter({
    required this.values,
    required this.labels,
    required this.primaryColor,
    required this.textColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double maxVal = values.reduce((curr, next) => curr > next ? curr : next);
    final double minVal = values.reduce((curr, next) => curr < next ? curr : next);
    final double valRange = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    final double labelHeight = 24.0;
    final double chartHeight = size.height - labelHeight;
    final double chartWidth = size.width;

    // Draw Grid Lines (Horizontal)
    const gridLineCount = 3;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= gridLineCount; i++) {
      final y = chartHeight * i / gridLineCount;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }

    final double stepX = chartWidth / (values.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final double normalizedY = (values[i] - minVal) / valRange;
      final double y = chartHeight - (normalizedY * (chartHeight - 20)) - 10;
      final double x = i * stepX;
      points.add(Offset(x, y));
    }

    // Path for line and gradient fill
    final path = Path();
    final fillPath = Path();

    path.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, chartHeight);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      final controlX1 = p1.dx + (p2.dx - p1.dx) / 2;
      final controlY1 = p1.dy;
      final controlX2 = p1.dx + (p2.dx - p1.dx) / 2;
      final controlY2 = p2.dy;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, p2.dx, p2.dy);
      fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, p2.dx, p2.dy);
    }

    fillPath.lineTo(points.last.dx, chartHeight);
    fillPath.close();

    // Paint line
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Paint gradient area
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primaryColor.withOpacity(0.3),
        primaryColor.withOpacity(0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTRB(0, 0, chartWidth, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw dots and labels
    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final dotOuterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotShadowPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];

      if (i == points.length - 1) {
        canvas.drawCircle(p, 9.0, dotShadowPaint);
        canvas.drawCircle(p, 6.0, dotPaint);
        canvas.drawCircle(p, 2.0, dotOuterPaint);
      } else {
        canvas.drawCircle(p, 3.5, dotPaint);
      }

      // Draw label
      final textSpan = TextSpan(
        text: labels[i],
        style: GoogleFonts.inter(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final textOffset = Offset(
        p.dx - textPainter.width / 2,
        chartHeight + 8,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
