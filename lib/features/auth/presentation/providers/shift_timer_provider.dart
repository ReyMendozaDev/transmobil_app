import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado del temporizador de jornada
class ShiftTimerState {
  final Duration elapsed;
  final bool isRunning;

  const ShiftTimerState({this.elapsed = Duration.zero, this.isRunning = false});

  ShiftTimerState copyWith({Duration? elapsed, bool? isRunning}) {
    return ShiftTimerState(
      elapsed: elapsed ?? this.elapsed,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

/// Notifier para manejar la lógica del temporizador
class ShiftTimerNotifier extends StateNotifier<ShiftTimerState> {
  Timer? _timer;

  ShiftTimerNotifier() : super(const ShiftTimerState());

  /// Inicia la jornada y el contador
  void startShift() {
    if (state.isRunning) return;

    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(
        elapsed: state.elapsed + const Duration(seconds: 1),
      );
    });
  }

  /// Finaliza la jornada y detiene el contador
  void endShift() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
  }

  /// Reinicia el contador a cero
  void reset() {
    _timer?.cancel();
    _timer = null;
    state = const ShiftTimerState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider global para el temporizador de jornada
final shiftTimerProvider =
    StateNotifierProvider<ShiftTimerNotifier, ShiftTimerState>((ref) {
      return ShiftTimerNotifier();
    });
