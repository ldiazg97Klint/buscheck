
import 'package:BusGo/models/ticket/tickets_model.dart';
import 'package:BusGo/models/trips/trips_model.dart';
import 'package:BusGo/util/globalCallApi/apiService.dart';
import 'package:BusGo/env.dart';

class TripsRepository {
  final ApiService authService;

  Future<dynamic> verifyQrTicket({required String qrData}) async {
    final endpoint = '${Env.apiEndpoint}/verify-qr-ticket';
    try {
      // Armar el body como lo necesite el backend
      final Map<String, dynamic> body = {'qr': qrData};

      final response = await authService.post(endpoint, body: body);

      if (response is Map<String, dynamic> && response.containsKey('body')) {
        final body = response['body'];
        if (body is Map<String, dynamic>) {
          // Supongamos que el back devuelve algo tipo {"qr_status": 1, "action": true, ...}
          return body;
        } else if (body is String) {
          // Mensaje de error del backend
          return body;
        }
      }

      // Respuesta inesperada
      throw Exception('Formato de respuesta inesperado: $response');
    } catch (e) {
      print('Error en verifyQrTicket: $e');
      throw Exception('verifyQrTicket: $e');
    }
  }

  TripsRepository({required this.authService});



  Future<dynamic> getTicketRepository(int branchId, String date) async {
    final endpoint = '${Env.apiEndpoint}/get-trip-branch-worker';
    final body = {
      'branch_id': branchId,
      'date': date,
    };

    try {
      // Llama al servicio y obtiene la respuesta procesada
      final response = await authService.post(endpoint, body: body);

      // Verificamos si la respuesta es un Map y si contiene el cuerpo
      if (response is Map<String, dynamic>) {
        // Verificamos si el campo 'body' está presente y es del tipo esperado
        if (response.containsKey('body')) {
          final body = response['body'];

          // Verificamos si 'body' es un Map
          if (body is Map<String, dynamic>) {
            // Si 'body' es un Map, deserializamos la respuesta a nuestro modelo Tickets
            final tripsResponse = Tickets.fromJson(
                body); // Aquí usamos Tickets.fromJson en lugar de tripsFromJson
            print('Datos de los viajes: $tripsResponse');
            return tripsResponse;
          } else if (body is String) {
            // Si es una String, significa que no hay viajes, retornamos null
            print('No hay viajes disponibles.');
            return null;
          } else {
            throw Exception('Formato inesperado en el campo "body".');
          }
        } else {
          throw Exception('Respuesta sin el campo "body".');
        }
      } else if (response is String) {
        print('Respuesta como String: $response');
        return response;
      } else {
        throw Exception(
            'Respuesta inesperada del servidor. Revise su conexión.');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('getTripssRepository: $e');
    }
  }

  Future<dynamic> getTripssRepository(int branchId) async {
    final endpoint = '${Env.apiEndpoint}/get-trip-date';
    final body = {
      'branch_id': branchId,
    };

    try {
      // Llama al servicio y obtiene la respuesta procesada
      final response = await authService.post(endpoint, body: body);

      // Verificamos si la respuesta es un Map y si contiene el cuerpo
      if (response is Map<String, dynamic>) {
        // Verificamos si el campo 'body' está presente y es del tipo esperado
        if (response.containsKey('body')) {
          final body = response['body'];

          // Verificamos si 'body' es un Map
          if (body is Map<String, dynamic>) {
            // Si 'body' es un Map, deserializamos la respuesta a nuestro modelo Trips
            final tripsResponse = Trips.fromJson(
                body); // Aquí usamos Trips.fromJson en lugar de tripsFromJson
            print('Datos de los viajes: $tripsResponse');
            return tripsResponse;
          } else if (body is String) {
            // Si es una String, significa que no hay viajes, retornamos null
            print('No hay viajes disponibles.');
            return null;
          } else {
            throw Exception('Formato inesperado en el campo "body".');
          }
        } else {
          throw Exception('Respuesta sin el campo "body".');
        }
      } else if (response is String) {
        print('Respuesta como String: $response');
        return response;
      } else {
        throw Exception(
            'Respuesta inesperada del servidor. Revise su conexión.');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('getTripssRepository: $e');
    }
  }



  Future<dynamic> updateTripRepository(Map<String, dynamic> data) async {
    final endpoint = '${Env.apiEndpoint}/trip-update';
    try {
      final response = await authService.post(endpoint, body: data);

      // Suponemos que la respuesta viene en un Map<String, dynamic> con clave 'body'
      if (response is Map<String, dynamic> && response.containsKey('body')) {
        final body = response['body'];
        if (body is Map<String, dynamic>) {
          // Deserializa a Trips (listado completo de viajes actualizado)
          return Trips.fromJson(body);
        } else if (body is String) {
          // Si el back devuelve un mensaje de error
          return body;
        }
      }
      // Respuesta inesperada
      throw Exception('Formato de respuesta inesperado: $response');
    } catch (e) {
      print('Error en updateTripRepository: $e');
      throw Exception('updateTripRepository: $e');
    }
  }
} //fin TripsRepository
