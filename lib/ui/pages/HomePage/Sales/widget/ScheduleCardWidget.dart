import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../domain/signals/tickets_signals/tickets_signal.dart';

class ScheduleCard extends StatefulWidget {
  final String name;
  final String origin;
  final String destination;
  final String plate;
  final String originImage;
  final String destinationImage;
  final String timeIni;
  final String timeFin;
  final String price;
  final String place;
  final int amount;
  final int seats;
  final int idTrip;
  final int seatsAvailable;
  final List<int> reservedSeats;

  const ScheduleCard(
      {super.key,
      required this.timeIni,
      required this.price,
      required this.timeFin,
      required this.place,
      required this.amount,
      required this.seats,
      required this.seatsAvailable,
      required this.idTrip,
      required this.originImage,
      required this.destinationImage,
      required this.name,
      required this.plate,
      required this.reservedSeats,
      required this.origin,
      required this.destination});

  @override
  _ScheduleCardState createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  bool isExpanded = false;
  bool _tripStarted = false;
  bool _tripFinished = false;
  Timer? _timer;

  int seats = availableSeatsSignal.value;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTrip() {
    setState(() {
      _tripStarted = true;
    });
    _timer = Timer(const Duration(minutes: 10), () {
      setState(() {
        _tripFinished = true;
      });
    });
  }

  Widget build(BuildContext context) {
    final timeToGo = _calculateTimeToGo(widget.timeIni, widget.timeFin);

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.99,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12), // Para efecto visual
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.grey, width: 0.5)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (timeToGo[1].isNotEmpty)
                      _infoText("Salida en:", timeToGo[0], timeToGo[1])
                    else
                      Text(
                        timeToGo[0],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    const VerticalDivider(
                      width: 5,
                    ),
                    _infoText("Capacidad:", '${widget.seats}'),
                    const VerticalDivider(
                      width: 5,
                    ),
                    _infoText("Abordaron:", '${widget.seats}'),
                    const VerticalDivider(
                      width: 5,
                    ),
                    _infoText("Pendientes:", '${widget.seatsAvailable}'),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _routeInfo(
                          getRegionFromAddress(
                              widget.origin), // Extraemos la región
                          "Salida: ${widget.timeIni}",
                          Icons.radio_button_checked,
                        ),
                        const SizedBox(height: 10),
                        _routeInfo(
                          getRegionFromAddress(
                              widget.destination), // Extraemos la región
                          "Llegada: ${widget.timeFin}",
                          Icons.location_on,
                          isDestination: true,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 55, 0, 0),
                          child: _buildActionButton(timeToGo),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(List<String> timeToGo) {
    final status = timeToGo[0];
    final unit = timeToGo[1];

    // 1. Aún no sale: ocultar
    if (unit.isNotEmpty) {
      return const SizedBox.shrink();
    }

    // 2. Abordando: mostrar deshabilitado
    if (status == 'Abordando' && !_tripStarted) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Abordando', style: TextStyle(color: Colors.white)),
      );
    }

    // 3. Salió y no iniciado: activar para iniciar viaje
    if (status == 'Salió' && !_tripStarted) {
      return ElevatedButton(
        onPressed: _startTrip,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child:
            const Text('Iniciar Viaje', style: TextStyle(color: Colors.white)),
      );
    }

    // 4. Viaje iniciado y aún no finalizado: deshabilitado
    if (_tripStarted && !_tripFinished) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child:
            const Text('Iniciar Viaje', style: TextStyle(color: Colors.white)),
      );
    }

    // 5. Fin de viaje: mostrar 'Fin Viaje'
    if (_tripFinished) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Finalizar Viaje',
            style: TextStyle(color: Colors.white)),
      );
    }

    // Fallback
    return const SizedBox.shrink();
  }

  Widget _infoText(String title, String value, [String? subtitle]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Row(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Roboto')),
            const VerticalDivider(
              width: 0.5,
            ),
            if (subtitle != null)
              Text(" $subtitle",
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  Widget _routeInfo(
    String title,
    String subtitle,
    IconData icon, {
    bool isDestination = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 18, color: isDestination ? Colors.orange : Colors.blue),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              limitTextLength(title, 23),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            // Aquí aplicamos el truncado y el TextOverflow.ellipsis
            Text(
              subtitle, // Limita a 20 caracteres
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
              maxLines: 1, // Limita el texto a una sola línea
              overflow:
                  TextOverflow.ellipsis, // Agrega "..." si el texto se desborda
            ),
          ],
        ),
      ],
    );
  }

  String limitTextLength(String text, int maxLength) {
    if (text.length > maxLength) {
      return '${text.substring(0, maxLength)}...'; // Recorta y agrega "..."
    }
    return text;
  }

  String getRegionFromAddress(String address) {
    // Dividimos la dirección por las comas y tomamos la última parte
    List<String> parts = address.split(',');
    // Retornamos la última parte, que sería la región
    return parts.isNotEmpty ? parts.last.trim() : '';
  }

  DateTime _parseFlexibleDateTime(String input) {
    final timeOnly = RegExp(r'^\d{2}:\d{2}(?::\d{2})?$');
    if (timeOnly.hasMatch(input)) {
      // Si es solo hora:minuto(:segundo), asumimos hoy
      final now = DateTime.now();
      final parts = input.split(':').map(int.parse).toList();
      final h = parts[0], m = parts[1], s = (parts.length == 3 ? parts[2] : 0);
      return DateTime(now.year, now.month, now.day, h, m, s);
    }
    // Si viene ISO completo, quitamos milisegundos y usamos DateTime.parse
    final cleaned = input.split('.').first;
    return DateTime.parse(cleaned);
  }

  String _calculateTravelTime(String start, String end) {
    final sTime = _parseFlexibleDateTime(start);
    final eTime = _parseFlexibleDateTime(end);
    final mins = eTime.difference(sTime).inMinutes;
    return mins.toString();
  }

  List<String> _calculateTimeToGo(String start, String end) {
    final now = DateTime.now();
    final s = _parseFlexibleDateTime(start);
    final diffM = s.difference(now).inMinutes;

    if (diffM <= 1) {
      return ['Salió', ''];
    }
    if (diffM <= 15) {
      return ['Abordando', ''];
    }
    // aún no sale
    if (diffM >= 60) {
      return ['${diffM ~/ 60}', 'h'];
    } else {
      return ['${diffM}', 'min'];
    }
  }
}
