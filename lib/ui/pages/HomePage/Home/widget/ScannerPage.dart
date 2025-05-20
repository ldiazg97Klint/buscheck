import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../../domain/signals/tickets_signals/tickets_signal.dart';
import '../../Sales/widget/ScheduleCardWidget.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  MobileScannerController controller = MobileScannerController();
  String? qrResult;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;

    if (!status.isGranted) {
      final result = await Permission.camera.request();

      if (result.isPermanentlyDenied) {
        // Si el usuario lo rechazó permanentemente, mostramos alerta
        _showPermissionDeniedDialog();
      }

      setState(() {
        _hasPermission = result.isGranted;
      });
    } else {
      setState(() => _hasPermission = true);
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso requerido'),
        content: const Text('Debes habilitar los permisos de cámara manualmente en Configuración'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => openAppSettings(), // Abre configuración de la app
            child: const Text('Abrir Configuración'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),

              // QR CAMERA VIEW
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildScannerView(),
                ),
              ),
              const SizedBox(height: 16),

              // CARD DE VIAJE
              tripsSignal.watch(context) == null ||
                      tripsSignal.watch(context)!.isEmpty
                  ? const Center(
                      child: Text(
                        "No hay recorridos disponibles",
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: tripsSignal.watch(context)!.length,
                      itemBuilder: (context, index) {
                        final trip = tripsSignal.watch(context)![index];
                        availableSeatsSignal.value =
                            trip.seats! - (trip.reservedSeats!.length);
                        return ScheduleCard(
                          name: trip.name ?? '',
                          origin: trip.origin ?? "Desconocido",
                          destination: trip.destination ?? "Desconocido",
                          plate: trip.plate ?? '',
                          originImage: trip.originImage ?? '',
                          destinationImage: trip.destinationImage ?? '',
                          timeIni: trip.schedule.toString(),
                          timeFin: trip.arrival.toString(),
                          place: trip.name ?? "Desconocido",
                          seats: trip.seats ?? 0,
                          idTrip: trip.id ?? 0,
                          reservedSeats: trip.reservedSeats ?? [],
                          price: '',
                          amount: 0,
                          seatsAvailable: 0,
                        );
                      },
                    ),

              const SizedBox(height: 16),

              // VALIDACIÓN (solo si hay QR escaneado)
              if (qrResult != null)
                _buildValidationCard("Ticket Validado Correctamente", "OK"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerView() {
    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No podemos acceder a la cámara'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _checkCameraPermission(); // Forzar nueva solicitud
                if (mounted) setState(() {});
              },
              child: const Text('SOLICITAR PERMISO'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            final String? code = capture.barcodes.first.rawValue;
            if (code != null && qrResult == null) {
              setState(() => qrResult = code);
              controller.stop();
            }
          },
        ),
        // Overlay personalizado (similar al original)
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.blue,
                width: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Los siguientes métodos se mantienen IGUALES que en tu código original:
  Widget _buildHeader() {
    return SizedBox(
      height: kToolbarHeight, // Altura estándar de AppBar
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Botón de retroceso alineado a la izquierda
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Título centrado
          const Text(
            'CHEQUEAR PASAJE',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationCard(String title, String status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.confirmation_num, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(status,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _infoItem extends StatelessWidget {
  final String title;
  final String value;
  const _infoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
