// lib/ui/pages/HomePage/Home/widget/trip_board_store.dart

import 'package:flutter/foundation.dart';

/// Guarda en memoria un ValueNotifier<int> por cada tripId.
class TripBoardStore {
  static final Map<int, ValueNotifier<int>> _notifiers = {};

  /// Obtiene (o crea) el ValueNotifier para este tripId, inicializado en 0.
  static ValueNotifier<int> notifier(int tripId) {
    return _notifiers.putIfAbsent(
      tripId,
          () => ValueNotifier<int>(0),
    );
  }

  /// Incrementa el contador “abordaron” para este tripId.
  static void increment(int tripId) {
    final n = notifier(tripId);
    n.value = n.value + 1;
  }

  /// Resetea el contador (útil al terminar el viaje o en pruebas).
  static void reset(int tripId) {
    notifier(tripId).value = 0;
  }
}
