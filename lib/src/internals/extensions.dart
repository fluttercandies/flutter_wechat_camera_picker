///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/9/30 17:02
///
import 'dart:async';

import 'package:flutter/widgets.dart';

extension SafeSetStateExtension on State {
  FutureOr<void> safeSetState(FutureOr<dynamic> Function() fn) async {
    await fn();
    if (mounted &&
        !context.debugDoingBuild &&
        context.owner?.debugBuilding != true) {
      // ignore: invalid_use_of_protected_member
      setState(() {});
    }
  }
}

extension NullableObjectExtension on Object? {
  StackTrace? get nullableStackTrace {
    if (this is Error?) {
      return (this as Error?)?.stackTrace;
    }
    return null;
  }
}
