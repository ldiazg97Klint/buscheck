import 'package:BusGo/models/ticket/tickets_model.dart';
import 'package:BusGo/models/trips/trips_model.dart';
import 'package:signals/signals.dart';

// Signals para manejar el estado
final Signal<Trip?> tripsSelectSignal = Signal<Trip?>(null);
// Señales relacionadas con Trips
final Signal<bool> isLoadingTripsSignal = Signal<bool>(false);
final Signal<List<Trip>?> tripsSignal = Signal<List<Trip>?>(null);
final Signal<String?> tripsErrorSignal = Signal<String?>(null);
// Señales relacionadas con Tickets
final Signal<bool> isLoadingTicketsSignal = Signal<bool>(false);
final Signal<bool> floatingActionButtonSignal = Signal<bool>(true);
final Signal<List<Ticket>?> ticketsSignal = Signal<List<Ticket>?>(null);
final Signal<String?> ticketsErrorSignal = Signal<String?>(null);
// Señales para verificar QR
final Signal<bool> isLoadingQrSignal = Signal<bool>(false);
final Signal<String?> qrErrorSignal = Signal<String?>(null);
final Signal<int?> qrStatusSignal = Signal<int?>(null);
final Signal<bool?> qrActionSignal = Signal<bool?>(null);
