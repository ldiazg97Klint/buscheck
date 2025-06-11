import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fases posibles del viaje
enum TripPhase { hidden, boarding, readyToStart, inProgress, finished }

/// Notifier que monitoriza el tiempo hasta el schedule
class TripPhaseNotifier extends StateNotifier<TripPhase> {
  final DateTime schedule;
  Timer? _timer;

  TripPhaseNotifier(this.schedule) : super(TripPhase.hidden) {
    _evaluate();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _evaluate());
  }

  void _evaluate() {
    final now = DateTime.now();
    final boardingTime = schedule.subtract(const Duration(minutes: 30));

    if (state == TripPhase.inProgress || state == TripPhase.finished) return;

    if (now.isBefore(boardingTime)) {
      state = TripPhase.hidden;
    } else if (now.isBefore(schedule)) {
      state = TripPhase.boarding;
    } else {
      state = TripPhase.readyToStart;
    }
  }

  void markInProgress() => state = TripPhase.inProgress;
  void markFinished() {
    state = TripPhase.finished;
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
