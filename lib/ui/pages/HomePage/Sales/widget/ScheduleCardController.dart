import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../../repository/trip_state_notifier.dart';

class ScheduleCardController {
  final BuildContext context;
  final TripPhase phase;
  final DateTime? start;
  final DateTime? end;
  final VoidCallback onStart;
  final VoidCallback onFinish;

  ScheduleCardController({
    required this.context,
    required this.phase,
    required this.start,
    required this.end,
    required this.onStart,
    required this.onFinish,
  });

  _ButtonConfig? getButtonConfig() {
    switch (phase) {
      case TripPhase.boarding:
        return _ButtonConfig(
          text: 'Abordando',
          color: Colors.blue,
          onPressed: () => GoRouter.of(context).push('/ScannerPage'),
        );
      case TripPhase.readyToStart:
        if (start == null && end == null) {
          return _ButtonConfig(
            text: 'Iniciar Viaje',
            color: Colors.green,
            onPressed: onStart,
          );
        }
        break;
      case TripPhase.inProgress:
        if (start != null && end == null) {
          return _ButtonConfig(
            text: 'Finalizar Viaje',
            color: Colors.orange,
            onPressed: onFinish,
          );
        }
        break;
      case TripPhase.finished:
        return _ButtonConfig(
          text: 'Viaje Finalizado',
          color: Colors.grey[600]!,
          onPressed: null,
        );
      default:
        return null;
    }
    return null;
  }

  List<String> calculateTimeToGo(String timeIni) {
    DateTime now = DateTime.now();
    DateTime departureTime = DateFormat("HH:mm").parse(timeIni);
    departureTime = DateTime(
      now.year,
      now.month,
      now.day,
      departureTime.hour,
      departureTime.minute,
    );

    Duration diff = departureTime.difference(now);

    if (diff.isNegative) {
      return ['Salió', ''];
    } else if (diff.inMinutes <= 30) {
      return ['Abordando', ''];
    } else {
      return [diff.inMinutes.toString(), 'min'];
    }
  }

  String getRegion(String address) {
    final parts = address.split(',');
    return parts.isNotEmpty ? parts.last.trim() : '';
  }

  String limitText(String text, int max) =>
      text.length > max ? '${text.substring(0, max)}...' : text;
}

class _ButtonConfig {
  final String text;
  final Color color;
  final VoidCallback? onPressed;

  _ButtonConfig({
    required this.text,
    required this.color,
    required this.onPressed,
  });
}
