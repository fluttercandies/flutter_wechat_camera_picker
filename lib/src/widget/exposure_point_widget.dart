///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-01-09 18:43
///
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'builder/tween_animation_builder_2.dart';

class ExposurePointWidget extends StatelessWidget {
  const ExposurePointWidget({
    Key key,
    @required this.size,
    @required this.color,
  })  : assert(size != null),
        assert(color != null),
        super(key: key);

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
    @required this.size,
    @required this.color,
    this.radius = 2,
    this.strokeWidth = 2,
  })  : assert(size != null),
        assert(size > 0),
        assert(color != null);

  final double size;
  final double radius;
  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Size _dividedSize = size / 3;
    final Paint _paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = strokeWidth;

    canvas
      // 左上角组弧
      ..drawLine(Offset(radius, 0), Offset(_dividedSize.width, 0), _paint)
      ..drawArc(
        Rect.fromCenter(
          center: Offset(radius, radius),
          width: radius * 2,
          height: radius * 2,
        ),
        -math.pi,
        math.pi / 2,
        false,
        _paint,
      )
      ..drawLine(Offset(0, _dividedSize.height), Offset(0, radius), _paint)
      // 右上角组弧
      ..drawLine(
        Offset(_dividedSize.width * 2, 0),
        Offset(size.width - radius, 0),
        _paint,
      )
      ..drawArc(
        Rect.fromCenter(
          center: Offset(size.width - radius, radius),
          width: radius * 2,
          height: radius * 2,
        ),
        -math.pi / 2,
        math.pi / 2,
        false,
        _paint,
      )
      ..drawLine(
        Offset(size.width, radius),
        Offset(size.width, _dividedSize.height),
        _paint,
      )
      // 右下角组弧
      ..drawLine(
        Offset(size.width, _dividedSize.height * 2),
        Offset(size.width, size.height - radius),
        _paint,
      )
      ..drawArc(
        Rect.fromCenter(
          center: Offset(size.width - radius, size.height - radius),
          width: radius * 2,
          height: radius * 2,
        ),
        0,
        math.pi / 2,
        false,
        _paint,
      )
      ..drawLine(
        Offset(size.height - radius, size.height),
        Offset(size.height - _dividedSize.width, size.height),
        _paint,
      )
      // 左下角组弧
      ..drawLine(
        Offset(_dividedSize.width, size.height),
        Offset(radius, size.height),
        _paint,
      )
      ..drawArc(
        Rect.fromCenter(
          center: Offset(radius, size.height - radius),
          width: radius * 2,
          height: radius * 2,
        ),
        math.pi / 2,
        math.pi / 2,
        false,
        _paint,
      )
      ..drawLine(
        Offset(0, size.height - radius),
        Offset(0, size.height - _dividedSize.height),
        _paint,
      )
      // 中心圆
      ..drawCircle(
        Offset(size.width / 2, size.height / 2),
        _dividedSize.width / 2,
        _paint,
      );
  }

  @override
  bool shouldRepaint(ExposurePointPainter oldDelegate) {
    return oldDelegate.size != size || oldDelegate.radius != radius;
  }
}
