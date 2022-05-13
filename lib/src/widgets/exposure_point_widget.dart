// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';

import 'builder/tween_animation_builder_2.dart';

class ExposurePointWidget extends StatelessWidget {
  const ExposurePointWidget({
    Key? key,
    required this.size,
    required this.color,
  }) : super(key: key);

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
              painter: ExposurePointPainter(size: size, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

/// A [CustomPaint] that draws the exposure point with four arcs and one circle.
/// 包含了四条弧及一个圆的曝光点绘制
class ExposurePointPainter extends CustomPainter {
  const ExposurePointPainter({
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
      // 先移动到左上组弧的顺时针起始位
      ..moveTo(0, dividedSize.height)
      // 左上组弧
      ..relativeLineTo(0, -lineLength)
      ..relativeArcToPoint(Offset(radius, -radius), radius: _circularRadius)
      ..relativeLineTo(lineLength, 0)
      // 移动至右上组弧起始位
      ..relativeMoveTo(dividedSize.width, 0)
      // 右上组弧
      ..relativeLineTo(lineLength, 0)
      ..relativeArcToPoint(Offset(radius, radius), radius: _circularRadius)
      ..relativeLineTo(0, lineLength)
      // 移动至右下组弧起始位
      ..relativeMoveTo(0, dividedSize.height)
      // 右下组弧
      ..relativeLineTo(0, lineLength)
      ..relativeArcToPoint(Offset(-radius, radius), radius: _circularRadius)
      ..relativeLineTo(-lineLength, 0)
      // 移动至左下组弧起始位
      ..relativeMoveTo(-dividedSize.width, 0)
      // 左下组弧
      ..relativeLineTo(-lineLength, 0)
      ..relativeArcToPoint(Offset(-radius, -radius), radius: _circularRadius)
      ..relativeLineTo(0, -lineLength)
      // 移动至左上组弧起始位
      ..relativeMoveTo(0, -dividedSize.height)
      ..close();
    canvas
      ..drawPath(path, paint)
      // 中心圆
      ..drawCircle(
        Offset(size.width / 2, size.height / 2),
        dividedSize.width / 2,
        paint,
      );
  }

  @override
  bool shouldRepaint(ExposurePointPainter oldDelegate) {
    return oldDelegate.size != size || oldDelegate.radius != radius;
  }
}
