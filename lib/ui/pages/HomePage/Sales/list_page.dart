import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../domain/signals/tickets_signals/tickets_signal.dart';
import '../../../../models/trips/trips_model.dart';
import '../Sales/widget/OrigenDestinoCard.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
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

  bool _isBoarding(Trip trip) {
    if (trip.schedule == null || trip.start != null) return false;
    final sched = _parseFlexible(trip.schedule!);
    final now = DateTime.now();
    return now.isAfter(sched.subtract(const Duration(minutes: 30))) &&
        now.isBefore(sched.add(const Duration(minutes: 10)));
  }

  @override
  Widget build(BuildContext context) {
    // Obtener todos los viajes
    final allTrips = tripsSignal.watch(context) ?? <Trip>[];
    // Filtrar solo los pendientes: no iniciados y no en abordaje
    final pendingTrips =
        allTrips.where((t) => t.start == null && !_isBoarding(t)).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Viajes  pendientes'),
      ),
      body: pendingTrips.isEmpty
          ? const Center(
              child: Text(
                "No hay viajes pendientes",
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: pendingTrips.length,
              itemBuilder: (context, index) {
                final t = pendingTrips[index];
                // formatear horas para mostrar
                final salida = t.schedule != null
                    ? DateFormat('HH:mm').format(_parseFlexible(t.schedule!))
                    : '';
                final llegada = t.arrival != null
                    ? DateFormat('HH:mm').format(_parseFlexible(t.arrival!))
                    : '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OrigenDestinoCard(
                    origen: t.origin ?? 'Desconocido',
                    destino: t.destination ?? 'Desconocido',
                    salida: salida,
                    llegada: llegada,
                    capacidad: t.seats ?? 0,
                  ),
                );
              },
            ),
    );
  }
}
