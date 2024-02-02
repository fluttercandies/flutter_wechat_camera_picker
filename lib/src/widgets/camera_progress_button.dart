// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:wechat_picker_library/wechat_picker_library.dart';

import '../internals/methods.dart';

final class CameraProgressButton extends StatefulWidget {
  const CameraProgressButton({
    super.key,
    required this.isAnimating,
    required this.isBusy,
    required this.size,
    required this.ringsWidth,
    this.ringsColor = defaultThemeColorWeChat,
    this.duration = const Duration(seconds: 15),
  });

  final bool isAnimating;
  final bool isBusy;
  final Size size;
  final double ringsWidth;
  final Color ringsColor;
  final Duration duration;

  @override
  State<CameraProgressButton> createState() => _CircleProgressState();
}

class _CircleProgressState extends State<CameraProgressButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController progressController;

  @override
  void initState() {
    super.initState();
    progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
      if (widget.isAnimating) {
        progressController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(CameraProgressButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBusy != oldWidget.isBusy) {
      if (widget.isBusy) {
        progressController
          ..reset()
          ..stop();
      } else {
        progressController.value = 0.0;
        if (!progressController.isAnimating) {
          progressController.forward();
        }
      }
    }
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        progressController.forward();
      } else {
        progressController.stop();
      }
    }
  }

  @override
  void dispose() {
    progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAnimating && !widget.isBusy) {
      return const SizedBox.shrink();
    }
    return Center(
      child: SizedBox.fromSize(
        size: widget.size,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: progressController,
            builder: (_, __) => CircularProgressIndicator(
              color: widget.ringsColor,
              strokeWidth: widget.ringsWidth,
              value: widget.isBusy ? null : progressController.value,
            ),
          ),
        ),
      ),
    );
  }
}
