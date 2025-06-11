import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'trip_state_notifier.dart';


final tripPhaseProvider = StateNotifierProvider.family<
    TripPhaseNotifier, TripPhase, DateTime>(
      (ref, schedule) => TripPhaseNotifier(schedule),
);
