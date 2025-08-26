import 'package:flutter/material.dart';
import 'dart:math' as math;

class FirstCustomWidget extends StatelessWidget {
  const FirstCustomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Light off-white background
      appBar: AppBar(
        title: const Text('Storage Meter'),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0.5,
      ),
      body: Center(
        child: SizeMeter(
          totalCapacity: 432, // Total storage capacity in GB
          arcs: const [
            (68, Color(0xFFFF9CE9), Icons.photo), // 42GB - Neon Pink
            (145, Color(0xFFFFF873), Icons.video_library), // 120GB - Neon Yellow
            (219, Color(0xFF9CFFF9), Icons.folder), // 350GB - Neon Cyan
          ],
          arcWidth: 12.0, // Reduced to 75% of 16.0
          spacing: 20.0, // Increased spacing for better separation
          arcSizeTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          dimmedTextColor: Colors.white70,
        ),
      ),
    );
  }
}

class SizeMeter extends StatelessWidget {
  final int? totalCapacity; // Total storage capacity in GB (optional, not used for arc length)
  final List<(int size, Color color, IconData icon)> arcs;
  final double arcWidth;
  final double spacing;
  final TextStyle arcSizeTextStyle;
  final Color dimmedTextColor;

  const SizeMeter({
    super.key,
    this.totalCapacity, // Made optional since we're using relative sizing
    required this.arcs,
    this.arcWidth = 10.0,
    this.spacing = 6.0,
    this.arcSizeTextStyle = const TextStyle(fontSize: 12, color: Color.fromARGB(255, 255, 255, 255)),
    this.dimmedTextColor = const Color.fromARGB(255, 255, 255, 255),
  });

  @override
  Widget build(BuildContext context) {
    const double meterSize = 280.0;
    const double maxSweepAngle = math.pi * 4 / 3; // 240 degrees for full capacity
    
    // Sort arcs by size (largest first for outermost positioning)
    final sortedArcs = List<(int, Color, IconData)>.from(arcs)..sort((a, b) => b.$1.compareTo(a.$1));
    final neonColors = [
      const Color(0xFF9CFFF9), // Cyan neon for largest (outermost)
      const Color(0xFFFF9CE9), // Pink neon for medium (middle)
      const Color(0xFF00BFFF), // Blue neon for smallest (innermost)
    ];

    // Find the largest arc size to use as reference for relative sizing
    final largestArcSize = sortedArcs.isNotEmpty ? sortedArcs.first.$1 : 1;

    // Assign colors based on position (largest gets cyan outermost, smallest gets blue innermost)
    final coloredArcs = sortedArcs.asMap().entries.map((entry) {
      final index = entry.key;
      final arc = entry.value;
      final color = index < neonColors.length ? neonColors[index] : neonColors.last;
      return (arc.$1, color, arc.$3); // Keep the original icon
    }).toList();

    return SizedBox(
      width: meterSize,
      height: meterSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              'Hello',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          // Arc layers from outermost to innermost
          ...coloredArcs.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final arc = entry.value;
              final radius = (meterSize / 2) - (index * (arcWidth + spacing));

              // Calculate arc length relative to the largest arc (not total capacity)
              final length = (arc.$1 / largestArcSize) * maxSweepAngle;

              return SizeMeterArc(
                size: arc.$1,
                color: arc.$2,
                icon: arc.$3,
                width: arcWidth,
                length: length,
                radius: radius,
                arcSizeTextStyle: arcSizeTextStyle,
                dimmedTextColor: dimmedTextColor,
              );
            },
          ),
        ],
      ),
    );
  }
}

class SizeMeterArc extends StatelessWidget {
  final int size;
  final Color color;
  final IconData icon;
  final double width;
  final double length; // in radians
  final double radius;
  final TextStyle arcSizeTextStyle;
  final Color dimmedTextColor;

  const SizeMeterArc({
    super.key,
    required this.size,
    required this.color,
    required this.icon,
    required this.width,
    required this.length,
    required this.radius,
    required this.arcSizeTextStyle,
    required this.dimmedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    const double startAngle = math.pi / 2; // Start from bottom-right (45 degrees)
    final endAngle = startAngle + length;

    // Position text slightly outside the end of the arc
    final textRadius = radius + 3;

    // Position icon at the start of the arc with right padding
    final iconRadius = radius + 8;
    final iconAngle = startAngle; // Position at the start of the arc

    // Rotate text to be tangent to the arc's end point
    final textRotationAngle = endAngle + math.pi / 2;

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Custom painted arc
          CustomPaint(
            size: Size(radius * 2, radius * 2),
            painter: ArcPainter(
              color: color,
              width: width,
              length: length,
              radius: radius,
              startAngle: startAngle,
            ),
          ),
          // Icon positioned at arc start
          Transform.translate(
            offset: Offset(
              iconRadius * math.cos(iconAngle),
              iconRadius * math.sin(iconAngle),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 50.0, bottom: 16), // Right padding
              child: Icon(
                icon,
                color: Colors.grey[200],
                size: 18.0,
              ),
            ),
          ),

          // Text positioned at arc end
          Transform.translate(
            offset: Offset(
              textRadius * math.cos(endAngle),
              textRadius * math.sin(endAngle),
            ),
            child: Transform.rotate(
              angle: textRotationAngle,
              child: Container(
                padding: const EdgeInsets.only(top: 8.0, left: 65),
                child: _buildTextWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$size',
          style: arcSizeTextStyle,
        ),
        const SizedBox(width: 2),
        Text(
          'GB',
          style: arcSizeTextStyle.copyWith(
            color: dimmedTextColor,
            fontSize: arcSizeTextStyle.fontSize! * 0.8,
          ),
        ),
      ],
    );
  }
}

class ArcPainter extends CustomPainter {
  final Color color;
  final double width;
  final double length;
  final double radius;
  final double startAngle;

  ArcPainter({
    required this.color,
    required this.width,
    required this.length,
    required this.radius,
    this.startAngle = -math.pi / 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Enhanced neon glow effect for dark background
    final outerGlowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = width + 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    // Inner glow effect
    final innerGlowPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = width + 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // Main arc
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw layers for maximum neon effect
    // Outer glow (widest, most transparent)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      length,
      false,
      outerGlowPaint,
    );

    // Inner glow (medium width, semi-transparent)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      length,
      false,
      innerGlowPaint,
    );

    // Main arc (core color, full opacity)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      length,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
