import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeService {
  static const double _shakeThreshold = 15.0;
  static const int _minTimeBetweenShakes = 600; // ms
  static const int _shakesRequired = 3;

  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime? _lastShakeTime;
  int _shakeCount = 0;
  VoidCallback? onShakeDetected;

  // Starts listening for shakes
  void start({required VoidCallback onShake}) {
    onShakeDetected = onShake;
    _shakeCount = 0;

    _subscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen((event) {
      _handleAccelerometer(event);
    });
  }

  void _handleAccelerometer(AccelerometerEvent event) {
    final double magnitude = sqrt(
      event.x * event.x +
      event.y * event.y +
      event.z * event.z,
    );

    // Subtract gravity (~9.8) to get actual motion force
    final double force = (magnitude - 9.8).abs();

    if (force > _shakeThreshold) {
      final now = DateTime.now();

      // Ignore too-rapid events (same shake)
      if (_lastShakeTime != null &&
          now.difference(_lastShakeTime!).inMilliseconds <
              _minTimeBetweenShakes) {
        return;
      }

      _lastShakeTime = now;
      _shakeCount++;

      if (_shakeCount >= _shakesRequired) {
        _shakeCount = 0;
        onShakeDetected?.call();
      }
    }
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _shakeCount = 0;
  }

  void dispose() {
    stop();
  }
}

// Simple typedef so we don't need to import Flutter just for VoidCallback
typedef VoidCallback = void Function();