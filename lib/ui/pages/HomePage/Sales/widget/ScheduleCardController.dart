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
    this.start,
    this.end,
    required this.onStart,
    required this.onFinish,
  });

  /// Configuración del botón según el estado del viaje
  ButtonConfig? getButtonConfig() {
    switch (phase) {
      case TripPhase.boarding:
        return ButtonConfig(
          text: 'Abordando',
          color: Colors.blue,
          onPressed: () => GoRouter.of(context).push('/ScannerPage'),
        );
      case TripPhase.readyToStart:
        if (start == null && end == null) {
          return ButtonConfig(
            text: 'Iniciar Viaje',
            color: Colors.green,
            onPressed: onStart,
          );
        }
        break;
      case TripPhase.inProgress:
        if (start != null && end == null) {
          return ButtonConfig(
            text: 'Finalizar Viaje',
            color: Colors.orange,
            onPressed: onFinish,
          );
        }
        break;
      case TripPhase.finished:
        return ButtonConfig(
          text: 'Viaje Finalizado',
          color: Colors.grey[600]!,
          onPressed: null,
        );
      default:
        return null;
    }
    return null;
  }

  /// Calcula tiempo restante para la salida en formato [valor, unidad]
  List<String> calculateTimeToGo(String timeIni) {
    final now = DateTime.now();
    DateTime departure = DateFormat('HH:mm').parse(timeIni);
    departure = DateTime(
      now.year,
      now.month,
      now.day,
      departure.hour,
      departure.minute,
    );
    final diff = departure.difference(now);
    if (diff.isNegative) {
      return ['Salió', ''];
    } else if (diff.inMinutes <= 30) {
      return ['Abordando', ''];
    } else {
      return [diff.inMinutes.toString(), 'min'];
    }
  }

  /// Extrae la región (última parte) de la dirección
  String getRegion(String address) {
    final parts = address.split(',');
    return parts.isNotEmpty ? parts.last.trim() : '';
  }

  /// Limita longitud de texto
  String limitText(String text, int max) {
    return text.length > max ? text.substring(0, max) + '...' : text;
  }
}

class ButtonConfig {
  final String text;
  final Color color;
  final VoidCallback? onPressed;

  ButtonConfig({
    required this.text,
    required this.color,
    required this.onPressed,
  });
}