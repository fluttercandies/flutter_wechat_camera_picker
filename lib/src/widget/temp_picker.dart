///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/15 22:22
///
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wechat_camera_picker/src/widget/circular_progress_bar.dart';
import 'package:flutter_common_exports/flutter_common_exports.dart';

class TempPicker extends StatefulWidget {
  @override
  _TempPickerState createState() => _TempPickerState();
}

class _TempPickerState extends State<TempPicker> {
  final Duration recordDetectDuration = kThemeChangeDuration;

  /// Whether the [shootingButton] should animate according to the gesture.
  /// 拍照按钮是否需要执行动画
  ///
  /// This happens when the [shootingButton] is being long pressed. It will animate
  /// for video recording state.
  /// 当长按拍照按钮时，会进入准备录制视频的状态，此时需要执行动画。
  bool isShootingButtonAnimate = false;

  /// Whether the recording progress should display.
  /// 视频录制的进度是否显示
  ///
  /// After [shootingButton] animated, the [CircleProgressBar] will become visible.
  /// 当拍照按钮动画执行结束后，进度将变为可见状态并开始更新其状态。
  bool isShowingProgress = false;

  Timer recordDetectTimer;

  /// The shooting button.
  /// 拍照按钮
  // TODO(Alex): Need further integration with video recording.
  Widget get shootingButton {
    final Size outerSize = Size.square(Screens.width / 3.5);
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerUp: (PointerUpEvent event) {
        recordDetectTimer?.cancel();
        if (isShowingProgress) {
          isShowingProgress = false;
          if (mounted) {
            setState(() {});
          }
        }
        if (isShootingButtonAnimate) {
          isShootingButtonAnimate = false;
          if (mounted) {
            setState(() {});
          }
        }
      },
      child: InkWell(
        borderRadius: maxBorderRadius,
        onTap: () {},
        onLongPress: () {
          recordDetectTimer = Timer(recordDetectDuration, () {
            isShowingProgress = true;
            if (mounted) {
              setState(() {});
            }
          });
          setState(() {
            isShootingButtonAnimate = true;
          });
        },
        child: SizedBox.fromSize(
          size: outerSize,
          child: Stack(
            children: <Widget>[
              Center(
                child: AnimatedContainer(
                  duration: kThemeChangeDuration,
                  width: isShootingButtonAnimate
                      ? outerSize.width
                      : (Screens.width / 5),
                  height: isShootingButtonAnimate
                      ? outerSize.height
                      : (Screens.width / 5),
                  padding: EdgeInsets.all(
                      Screens.width / (isShootingButtonAnimate ? 10 : 35)),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    shape: BoxShape.circle,
                  ),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              if (isShowingProgress)
                CircleProgressBar(
                  duration: 15.seconds,
                  outerRadius: outerSize.width,
                  ringsWidth: 2.0,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            shootingButton,
          ],
        ),
      ),
    );
  }
}
