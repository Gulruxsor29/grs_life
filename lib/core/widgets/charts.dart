import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class RingProgress extends StatelessWidget {
  const RingProgress({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 12,
    this.center,
    this.colors = const [AppColors.roseGold, AppColors.copper],
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Widget? center;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              colors: colors,
            ),
          ),
          if (center != null) SizedBox(width: size * 0.7, child: Center(child: center!)),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.colors,
  });

  final double progress;
  final double strokeWidth;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = strokeWidth;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.card;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint);

    if (progress <= 0) return;

    final gradient = SweepGradient(
      colors: [...colors, colors.first],
      startAngle: 0,
      endAngle: math.pi * 2,
      transform: const GradientRotation(-math.pi / 2),
    );
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect)
      ..color = colors.first;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.progress != progress;
}

class DonutSegment {
  const DonutSegment({required this.value, required this.color});

  final double value;
  final Color color;
}

class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.segments,
    this.size = 150,
    this.strokeWidth = 22,
    this.center,
  });

  final List<DonutSegment> segments;
  final double size;
  final double strokeWidth;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _DonutPainter(
              segments: segments,
              strokeWidth: strokeWidth,
            ),
          ),
          if (center != null) SizedBox(width: size * 0.55, child: Center(child: center!)),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments, required this.strokeWidth});

  final List<DonutSegment> segments;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    final stroke = strokeWidth;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..color = AppColors.card;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint);

    if (total <= 0) return;

    var start = -math.pi / 2;
    final gap = segments.length > 1 ? 0.03 : 0.0;
    for (final segment in segments) {
      final sweep = math.pi * 2 * (segment.value / total);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = segment.color;
      canvas.drawArc(rect, start + gap / 2, math.max(0.001, sweep - gap), false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) => oldDelegate.segments != segments;
}

class BarDatum {
  const BarDatum({required this.label, required this.value, this.highlight = false});

  final String label;
  final double value;
  final bool highlight;
}

class BarChart extends StatelessWidget {
  const BarChart({
    super.key,
    required this.data,
    this.height = 160,
    this.barColor = AppColors.roseGold,
    this.highlightColor = AppColors.copper,
  });

  final List<BarDatum> data;
  final double height;
  final Color barColor;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _BarPainter(
          data: data,
          barColor: barColor,
          highlightColor: highlightColor,
          labelStyle: Theme.of(context).textTheme.labelSmall!,
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.data,
    required this.barColor,
    required this.highlightColor,
    required this.labelStyle,
  });

  final List<BarDatum> data;
  final Color barColor;
  final Color highlightColor;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.fold<double>(0, (m, d) => math.max(m, d.value));
    final labelSpace = 18.0;
    final chartHeight = size.height - labelSpace;
    final slot = size.width / data.length;
    final barWidth = math.min(26.0, slot * 0.55);

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = chartHeight - chartHeight * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (var i = 0; i < data.length; i++) {
      final datum = data[i];
      final h = maxVal <= 0 ? 0.0 : (datum.value / maxVal) * (chartHeight - 8);
      final cx = slot * i + slot / 2;
      if (h > 2) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - barWidth / 2, chartHeight - h, barWidth, h),
          const Radius.circular(7),
        );
        final paint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              datum.highlight ? highlightColor : barColor,
              (datum.highlight ? highlightColor : barColor).withOpacity(0.35),
            ],
          ).createShader(rect.outerRect);
        canvas.drawRRect(rect, paint);
      }
      final tp = TextPainter(
        text: TextSpan(text: datum.label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, chartHeight + 4));
    }
  }

  @override
  bool shouldRepaint(_BarPainter oldDelegate) => oldDelegate.data != data;
}
