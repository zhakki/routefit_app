import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';

class StepService {
  StreamSubscription<StepCount>? _stepSubscription;

  int? _startSteps;
  int _currentSteps = 0;
  bool _isAvailable = true;
  bool _isCounting = false;

  int get currentRouteSteps {
    if (!_isAvailable || _startSteps == null) {
      return 0;
    }

    final steps = _currentSteps - _startSteps!;

    if (steps < 0) {
      return 0;
    }

    return steps;
  }

  void startCounting() {
    if (_isCounting) {
      return;
    }

    _startSteps = null;
    _currentSteps = 0;
    _isAvailable = true;
    _isCounting = true;

    _stepSubscription = Pedometer.stepCountStream.listen(
          (StepCount event) {
        _currentSteps = event.steps;
        _startSteps ??= event.steps;
      },
      onError: (error) {
        _isAvailable = false;
        _isCounting = false;

        debugPrint('Step counter is not available on this device: $error');

        _stepSubscription?.cancel();
        _stepSubscription = null;
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
    _isCounting = false;

    return steps;
  }

  void dispose() {
    _stepSubscription?.cancel();
  }
}