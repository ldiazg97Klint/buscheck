import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals/signals_flutter.dart';
import 'package:intl/intl.dart';
import 'package:BusGo/ui/pages/HomePage/Home/widget/ModuleCard.dart';
import 'package:BusGo/util/util_class_sharedPreferences.dart';
import '../../../../data/services/trips_service.dart';
import '../../../../domain/signals/tickets_signals/tickets_signal.dart';
import '../../../../models/trips/trips_model.dart';
import '../../../../repository/providers.dart';
import '../Sales/widget/ScheduleCardWidget.dart';


class TimeNotifier extends StateNotifier<DateTime> {
  TimeNotifier() : super(DateTime.now()) {
    Timer.periodic(const Duration(minutes: 1), (_) {
      state = DateTime.now();
    });
  }
}


final timeProvider = StateNotifierProvider<TimeNotifier, DateTime>((ref) {
  return TimeNotifier();
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final SharedPreferencesStorage _prefs = SharedPreferencesStorage();
  Color _colorModuleTicket = Colors.lightGreen;

  @override
  void initState() {
    super.initState();
    _prefs.getCounter().then((c) {
      final newColor = c > 0 ? Colors.amber[900]! : Colors.lightGreen;
      if (newColor != _colorModuleTicket) {
        setState(() => _colorModuleTicket = newColor);
      }
    });
  }

  DateTime _parseFlexible(String input) {
    if (input.contains('-')) {
      return DateTime.parse(input).toLocal();
    } else {
      final parts = input.split(':');
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }
  }


  Trip? _getActiveTrip(List<Trip> trips, DateTime now) {
    for (var trip in trips) {
      if (trip.schedule != null) {
        final sched = _parseFlexible(trip.schedule!);

        // Within 30 minutes before departure
        if (now.isAfter(sched.subtract(const Duration(minutes: 30))) &&
            now.isBefore(sched)) {
          print('Comprobacion de viaje');
          return trip;
        }
        // Trip started but not finished
        if (trip.start != null && trip.end == null) {
          print('Comprobacion de viaje no finalizado');
          return trip;
        }
        // Trip finished within last 5 minutes to allow final state view
        if (trip.end != null && now.difference(trip.end!).inMinutes <= 5) {
          print('comprobacion de viaje finalizado');
          return trip;
        }
      }
    }
    print('No hay viaje activo');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Watch current time to rebuild every minute
    final currentTime = ref.watch(timeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SingleChildScrollView(
        child: Watch(
              (context) {
            final trips = tripsSignal.value ?? <Trip>[];
            final activeTrip = _getActiveTrip(trips, currentTime);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activeTrip != null)
                  Consumer(
                    builder: (c, ref, _) {
                      final schedDt = _parseFlexible(activeTrip.schedule!);
                      final phase = ref.watch(tripPhaseProvider(schedDt));
                      return ScheduleCard(
                        name: activeTrip.name ?? '',
                        origin: activeTrip.origin ?? '',
                        destination: activeTrip.destination ?? '',
                        timeIni: DateFormat('HH:mm').format(schedDt),
                        timeFin: DateFormat('HH:mm')
                            .format(_parseFlexible(activeTrip.arrival!)),
                        seats: activeTrip.seats ?? 0,
                        idTrip: activeTrip.id ?? 0,
                        start: activeTrip.start,
                        end: activeTrip.end,
                        phase: phase,
                        onStart: () {
                          ref
                              .read(tripPhaseProvider(schedDt).notifier)
                              .markInProgress();
                          TripsService.updateTrip({
                            'id': activeTrip.id,
                            'start': DateFormat('yyyy-MM-dd HH:mm')
                                .format(DateTime.now())
                          });
                        },
                        onFinish: () {
                          ref
                              .read(tripPhaseProvider(schedDt).notifier)
                              .markFinished();
                          TripsService.updateTrip({
                            'id': activeTrip.id,
                            'end': DateFormat('yyyy-MM-dd HH:mm')
                                .format(DateTime.now())
                          });
                        },
                      );
                    },
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        "No hay viajes pendientes, acceda al listado para ver los próximos viajes",
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ModuleCard(
                        color: Colors.blue,
                        icon: Icons.list_outlined,
                        title: 'Listado',
                        description: 'Viajes próximos',
                        route: '/tripList',
                      ),
                      ModuleCard(
                        color: Colors.orange,
                        icon: Icons.bar_chart,
                        title: 'Reportes',
                        description: 'Estadísticas',
                        // route: '/ScannerPage',
                        route: '/ReportPage'
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
