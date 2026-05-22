import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';

class StepService {
  StreamSubscription<StepCount>? _stepSubscription;

  int? _startSteps;
  int _currentSteps = 0;

  int get currentRouteSteps {
    if (_startSteps == null) {
      return 0;
    }

    final steps = _currentSteps - _startSteps!;
    return steps < 0 ? 0 : steps;
  }

  void startCounting() {
    _startSteps = null;
    _currentSteps = 0;

    _stepSubscription = Pedometer.stepCountStream.listen(
          (StepCount event) {
        _currentSteps = event.steps;

        _startSteps ??= event.steps;
      },
      onError: (error) {
        debugPrint('Pedometer error: $error');
      },
      cancelOnError: false,
    );
  }

  Future<int> stopCounting() async {
    final steps = currentRouteSteps;

    await _stepSubscription?.cancel();
    _stepSubscription = null;
    _startSteps = null;
    _currentSteps = 0;

    return steps;
  }

  void dispose() {
    _stepSubscription?.cancel();
  }
}