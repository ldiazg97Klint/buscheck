import 'package:BusGo/domain/signals/tickets_signals/tickets_signal.dart';
import 'package:BusGo/models/trips/trips_model.dart';
import 'package:BusGo/repository/trips_repository.dart';
import '../../util/globalCallApi/apiService.dart';

final _tripsRepository = TripsRepository(authService: ApiService());

class TripsService {
  /// Actualiza inicio o fin de viaje llamando a POST /trip-update
  static Future<void> updateTrip(Map<String, dynamic> data) async {
    // Indica cargar
    isLoadingTripsSignal.value = true;
    tripsErrorSignal.value = null;

    try {
      final result = await _tripsRepository.updateTripRepository(data);

      if (result is Trips) {
        // Actualiza lista completa
        tripsSignal.value = result.trips;
        // Actualiza viaje seleccionado si coincide
        tripsSelectSignal.value =
            result.trips?.firstWhere((t) => t.id == data['id']);
      } else if (result is String) {
        // Mensaje de error del backend
        tripsErrorSignal.value = result;
      }
    } catch (e) {
      tripsErrorSignal.value = 'Error al actualizar viaje: $e';
    } finally {
      isLoadingTripsSignal.value = false;
    }
  }
}
