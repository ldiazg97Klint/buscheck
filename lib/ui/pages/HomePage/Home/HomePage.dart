import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:BusGo/ui/pages/HomePage/Home/widget/ModuleCard.dart';
import 'package:BusGo/util/util_class_sharedPreferences.dart';
import '../../../../domain/signals/tickets_signals/tickets_signal.dart';
import '../../../../models/trips/trips_model.dart';
import '../Sales/widget/ScheduleCardWidget.dart';
import '../Sales/widget/travel_list.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SharedPreferencesStorage sharedPreferencesStorage =
  SharedPreferencesStorage();
  Color colorModuleTicket = Colors.lightGreen;

  @override
  Widget build(BuildContext context) {
    // Reactualizar color tras render
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final c = await sharedPreferencesStorage.getCounter();
      final newColor = c > 0 ? Colors.amber[900]! : Colors.lightGreen;
      if (newColor != colorModuleTicket) {
        colorModuleTicket = newColor;
        setState(() {});
      }
    });

    final now = DateTime.now();
    final trips = tripsSignal.watch(context) ?? <Trip>[];

    // 1) Filtrar viajes en la ventana [now−10min, now]
    final recentTrips = trips.where((t) {
      try {
        final sched = DateTime.parse(t.schedule!);
        final diff = now.difference(sched).inMinutes;
        return diff >= 0 && diff <= 10;
      } catch (_) {
        return false;
      }
    }).toList();

    // 2) Coger sólo el primero (si existe)
    final Trip? currentTrip =
    recentTrips.isNotEmpty ? recentTrips.first : null;

    // 3) El resto de viajes (excluyendo el actual si lo hay)
    final otherTrips = currentTrip != null
        ? trips.where((t) => t.id != currentTrip.id).toList()
        : trips;

    // Widget de módulos (siempre abajo del ScheduleCard si existe)
    Widget moduleRow = const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ModuleCard(
            color: Colors.blue,
            icon: Icons.qr_code_scanner_outlined,
            title: 'Scanner',
            description: 'Scanner de Tickets',
            route: '/ScannerPage',
          ),
          ModuleCard(
            color: Colors.orange,
            icon: Icons.bar_chart,
            title: 'Reportes',
            description: 'Módulo de reportes y estadísticas',
            route: '/ReportsPage',
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Si hay un viaje “actual”, lo mostramos primero
            if (currentTrip != null) ...[
              ScheduleCard(
                name: currentTrip.name ?? '',
                origin: currentTrip.origin ?? 'Desconocido',
                destination: currentTrip.destination ?? 'Desconocido',
                plate: currentTrip.plate ?? '',
                originImage: currentTrip.originImage ?? '',
                destinationImage: currentTrip.destinationImage ?? '',
                timeIni: DateFormat('HH:mm')
                    .format(DateTime.parse(currentTrip.schedule!).toLocal()),
                timeFin: DateFormat('HH:mm')
                    .format(DateTime.parse(currentTrip.arrival!).toLocal()),
                place: currentTrip.name ?? 'Desconocido',
                seats: currentTrip.seats ?? 0,
                idTrip: currentTrip.id ?? 0,
                reservedSeats: currentTrip.reservedSeats ?? [],
                price: '',
                amount: 0,
                seatsAvailable: (currentTrip.seats ?? 0) -
                    (currentTrip.reservedSeats?.length ?? 0),
              ),
            ],

            // Siempre después (o único contenido si no hay currentTrip)
            moduleRow,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Listado de Viajes',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () =>
                      GoRouter.of(context).push('/StatisticsPageAll'),
                  child: const Text(
                    'Ver todas',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Listado del resto de viajes
            if (otherTrips.isEmpty)
              const Center(
                child: Text(
                  "No hay recorridos disponibles",
                  style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: otherTrips.length,
                itemBuilder: (context, i) {
                  final t = otherTrips[i];
                  // Parseo con DateTime.parse()
                  final sched = DateTime.parse(t.schedule!).toLocal();
                  final arr = DateTime.parse(t.arrival!).toLocal();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OrigenDestinoCard(
                      origen: t.origin ?? 'Desconocido',
                      destino: t.destination ?? 'Desconocido',
                      salida: DateFormat('HH:mm').format(sched),
                      llegada: DateFormat('HH:mm').format(arr),
                      capacidad: t.seats ?? 0,
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
