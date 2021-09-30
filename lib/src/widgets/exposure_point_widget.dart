///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-01-09 18:43
///
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
    final Size _dividedSize = size / 3;
    final double _lineLength = _dividedSize.width - radius;
    final Paint _paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = strokeWidth;

    final Path path = Path()
      // 先移动到左上组弧的顺时针起始位
      ..moveTo(0, _dividedSize.height)
      // 左上组弧
      ..relativeLineTo(0, -_lineLength)
      ..relativeArcToPoint(Offset(radius, -radius), radius: _circularRadius)
      ..relativeLineTo(_lineLength, 0)
      // 移动至右上组弧起始位
      ..relativeMoveTo(_dividedSize.width, 0)
      // 右上组弧
      ..relativeLineTo(_lineLength, 0)
      ..relativeArcToPoint(Offset(radius, radius), radius: _circularRadius)
      ..relativeLineTo(0, _lineLength)
      // 移动至右下组弧起始位
      ..relativeMoveTo(0, _dividedSize.height)
      // 右下组弧
      ..relativeLineTo(0, _lineLength)
      ..relativeArcToPoint(Offset(-radius, radius), radius: _circularRadius)
      ..relativeLineTo(-_lineLength, 0)
      // 移动至左下组弧起始位
      ..relativeMoveTo(-_dividedSize.width, 0)
      // 左下组弧
      ..relativeLineTo(-_lineLength, 0)
      ..relativeArcToPoint(Offset(-radius, -radius), radius: _circularRadius)
      ..relativeLineTo(0, -_lineLength)
      // 移动至左上组弧起始位
      ..relativeMoveTo(0, -_dividedSize.height)
      ..close();
    canvas
      ..drawPath(path, _paint)
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
