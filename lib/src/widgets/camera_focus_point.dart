// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:wechat_picker_library/wechat_picker_library.dart';

final class CameraFocusPoint extends StatelessWidget {
  const CameraFocusPoint({
    super.key,
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder2<double, double>(
      firstTween: Tween<double>(begin: 0, end: 1),
      secondTween: Tween<double>(begin: 1.5, end: 1),
      secondTweenCurve: Curves.easeOutBack,
      secondTweenDuration: const Duration(milliseconds: 400),
      builder: (_, double opacity, double scale) => Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: SizedBox.fromSize(
            size: Size.square(size),
            child: CustomPaint(
              painter: CameraFocusPointPainter(size: size, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

/// A [CustomPaint] that draws the exposure point with four arcs and one circle.
/// 包含了四条弧及一个圆的曝光点绘制。
final class CameraFocusPointPainter extends CustomPainter {
  const CameraFocusPointPainter({
    required this.size,
    required this.color,
    this.radius = 2,
    this.strokeWidth = 2,
  }) : assert(size > 0);

  final double size;
  final double radius;
  final double strokeWidth;
  final Color color;

  Radius get _circularRadius => Radius.circular(radius);

  @override
  void paint(Canvas canvas, Size size) {
    final Size dividedSize = size / 3;
    final double lineLength = dividedSize.width - radius;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = strokeWidth;

    final Path path = Path()
      // Move to the start of the arc-line group at the left-top.
      ..moveTo(0, dividedSize.height)
      // Draw arc-line group from the left-top.
      ..relativeLineTo(0, -lineLength)
      ..relativeArcToPoint(Offset(radius, -radius), radius: _circularRadius)
      ..relativeLineTo(lineLength, 0)
      // Move to the start of the arc-line group at the right-top.
      ..relativeMoveTo(dividedSize.width, 0)
      // Draw arc-line group from the right-top.
      ..relativeLineTo(lineLength, 0)
      ..relativeArcToPoint(Offset(radius, radius), radius: _circularRadius)
      ..relativeLineTo(0, lineLength)
      // Move to the start of the arc-line group at the right-bottom.
      ..relativeMoveTo(0, dividedSize.height)
      // Draw arc-line group from the right-bottom.
      ..relativeLineTo(0, lineLength)
      ..relativeArcToPoint(Offset(-radius, radius), radius: _circularRadius)
      ..relativeLineTo(-lineLength, 0)
      // Move to the start of the arc-line group at the left-bottom.
      ..relativeMoveTo(-dividedSize.width, 0)
      // Draw arc-line group from the left-bottom.
      ..relativeLineTo(-lineLength, 0)
      ..relativeArcToPoint(Offset(-radius, -radius), radius: _circularRadius)
      ..relativeLineTo(0, -lineLength)
      // Move to the start of the arc-line group at the left-top.
      ..relativeMoveTo(0, -dividedSize.height)
      ..close();
    canvas
      ..drawPath(path, paint)
      // Draw the center circle.
      ..drawCircle(
        Offset(size.width / 2, size.height / 2),
        dividedSize.width / 2,
        paint,
      );
  }

  @override
  bool shouldRepaint(CameraFocusPointPainter oldDelegate) {
    return oldDelegate.size != size ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color;
  }
}
