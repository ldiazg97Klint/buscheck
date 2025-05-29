import 'package:BusGo/domain/signals/tickets_signals/tickets_signal.dart';
import 'package:BusGo/models/ticket/tickets_model.dart';
import 'package:BusGo/models/trips/trips_model.dart';
import 'package:BusGo/repository/trips_repository.dart';
import 'package:BusGo/util/globalCallApi/apiService.dart'; // Ajustar según tu estructura

final tripsRepository = TripsRepository(
    authService: ApiService()); // Crear repositorio si no lo tienes



Future<void> getTickets(int branchId, String date) async {
  isLoadingTicketsSignal.value = true; // Indicamos que está cargando
  ticketsErrorSignal.value = null; // Limpiamos posibles errores previos
  ticketsSignal.value = null;

  try {
    final result = await tripsRepository.getTicketRepository(
        branchId, date); // Llamada al backend

    if (result is Tickets) {
      ticketsSignal.value =
          result.tickets; // Actualizamos las señales con los datos
    } else if (result is String) {
      ticketsErrorSignal.value =
          result; // Guardamos el mensaje de error si aplica
    }
  } catch (e) {
    ticketsErrorSignal.value = "Error: ${e.toString()}"; // Error inesperado
  } finally {
    isLoadingTicketsSignal.value = false; // Finalizamos el estado de carga
  }
}

Future<void> fetchTrips(int branchId) async {
  isLoadingTripsSignal.value = true; // Indicamos que está cargando
  tripsErrorSignal.value = null; // Limpiamos posibles errores previos

  try {
    final result = await tripsRepository
        .getTripssRepository(branchId); // Llamada al backend

    if (result is Trips) {
      tripsSignal.value =
          result.trips; // Actualizamos las señales con los datos
    } else if (result is String) {
      tripsErrorSignal.value =
          result; // Guardamos el mensaje de error si aplica
    }
  } catch (e) {
    tripsErrorSignal.value = "Error: ${e.toString()}"; // Error inesperado
  } finally {
    isLoadingTripsSignal.value = false; // Finalizamos el estado de carga
  }
}

// 🚀 Servicio para verificar QR
Future<void> verifyQrTicketService(String qrData) async {
  isLoadingQrSignal.value = true;
  qrErrorSignal.value = null;

  try {
    final result = await tripsRepository.verifyQrTicket(qrData: qrData);

    if (result is Map<String, dynamic>) {
      qrStatusSignal.value = result['qr_status'];
      qrActionSignal.value = result['action'];
    } else if (result is String) {
      qrErrorSignal.value = result;
    }
  } catch (e) {
    qrErrorSignal.value = "Error al verificar QR: $e";
  } finally {
    isLoadingQrSignal.value = false;
  }
}



void dataSelectedRoute(int idTrip) {
  // Verifica si tripsSignal no es null y contiene datos
  if (tripsSignal.value != null) {
    // Filtra los viajes que coinciden con el idTrip
    final filteredTrips =
        tripsSignal.value!.where((trip) => trip.id == idTrip).toList();
    // Actualiza tripsSelectSignal con los viajes filtrados
    tripsSelectSignal.value =
        filteredTrips.isNotEmpty ? filteredTrips.first : null;
  } else {
    // Si no hay datos en tripsSignal, tripsSelectSignal también debe ser null
    tripsSelectSignal.value = null;
  }
  print('ruta seleccionada:${tripsSelectSignal.value}');
}
