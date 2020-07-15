///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/15 21:13
///
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../constants/constants.dart';

class CircleProgressBar extends StatefulWidget {
  const CircleProgressBar({
    Key key,
    @required this.outerRadius,
    @required this.ringsWidth,
    this.ringsColor = C.themeColor,
    this.progress = 0.0,
    this.duration = const Duration(seconds: 15),
  }) : super(key: key);

  final double outerRadius;
  final double ringsWidth;
  final Color ringsColor;
  final double progress;
  final Duration duration;

  @override
  State<StatefulWidget> createState() => CircleProgressState();
}

class CircleProgressState extends State<CircleProgressBar>
    with SingleTickerProviderStateMixin {
  final GlobalKey paintKey = GlobalKey();
  final StreamController<double> progressStreamController =
      StreamController<double>.broadcast();

  AnimationController progressController;
  Animation<double> progressAnimation;
  CurvedAnimation progressCurvedAnimation;

  @override
  void initState() {
    super.initState();

    progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    progressController.value = widget.progress ?? 0.0;

    progressCurvedAnimation = CurvedAnimation(
      parent: progressController,
      curve: Curves.linear,
    );

    progressAnimation = Tween<double>(
      begin: widget.progress ?? 0.0,
      end: 1.0,
    ).animate(progressCurvedAnimation);

    progressController.addListener(() {
      progressStreamController.add(progressController.value);
    });

    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      progressController.forward();
    });
  }

  @override
  void dispose() {
    progressController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = Size.square(widget.outerRadius * 2);
    return Center(
      child: StreamBuilder<double>(
        initialData: 0.0,
        stream: progressStreamController.stream,
        builder: (BuildContext _, AsyncSnapshot<double> snapshot) {
          return CustomPaint(
            key: paintKey,
            size: size,
            painter: ProgressPainter(
              progress: snapshot.data,
              ringsWidth: widget.ringsWidth,
              ringsColor: widget.ringsColor,
            ),
          );
        },
      ),
    );
  }
}

class ProgressPainter extends CustomPainter {
  const ProgressPainter({
    this.ringsWidth,
    this.ringsColor,
    this.progress,
  });

  final double ringsWidth;
  final Color ringsColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final double center = size.width / 2;
    final Offset offsetCenter = Offset(center, center);
    final double drawRadius = size.width / 2 - ringsWidth;
    final double angle = 360.0 * progress;
    final double radians = angle.toRad;

    final double outerRadius = center;
    final double innerRadius = center - ringsWidth * 2;

//    if (progress > 0.0) {
    final double progressWidth = outerRadius - innerRadius;
//      if (radians > 0.0) {
    canvas.save();
    canvas.translate(0.0, size.width);
    canvas.rotate(-90.0.toRad);
    final Rect arcRect = Rect.fromCircle(
      center: offsetCenter,
      radius: drawRadius,
    );
    final Paint progressPaint = Paint()
      ..color = ringsColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = progressWidth;
    canvas
      ..drawArc(arcRect, 0, radians, false, progressPaint)
      ..restore();
//      }
//    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

extension _MathExtension on double {
  double get toRad => this * (math.pi / 180.0);

  double get toDeg => this * (180.0 / math.pi);
}
