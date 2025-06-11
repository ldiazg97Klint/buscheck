import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../util/globalCallApi/apiService.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../../repository/trips_repository.dart';


class QrScannerPage extends ConsumerStatefulWidget {
  const QrScannerPage({super.key});

  @override
  ConsumerState<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends ConsumerState<QrScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  final TripsRepository tripsRepository =
      TripsRepository(authService: ApiService());

  String? qrResult;
  bool _hasPermission = false;
  bool _isLoading = false;
  String? _validationTitle;
  String? _validationStatus;
  Color? _validationColor;

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
        content: const Text(
            'Debes habilitar los permisos de cámara manualmente en Configuración'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
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

  Future<void> _validateTicket(String qrData) async {
    setState(() {
      _isLoading = true;
      _validationTitle = null;
      _validationStatus = null;
    });

    try {
      final result = await tripsRepository.verifyQrTicket(qrData: qrData);

      final qrStatus = result['qr_status'] as int? ?? 0;
      final action = result['action'] as bool? ?? false;

      if (qrStatus == 1 && action) {
        _validationTitle = 'Ticket validado correctamente';
        _validationStatus = 'OK';
        _validationColor = Colors.green;
      } else if (qrStatus > 1) {
        _validationTitle = 'Ticket ya escaneado previamente';
        _validationStatus = 'Error';
        _validationColor = Colors.orange;
      } else {
        _validationTitle = 'Ticket inválido';
        _validationStatus = 'Error';
        _validationColor = Colors.red;
      }
    } on Exception catch (e) {
      print('ERROR CAPTURADO: $e');

      final msg = e.toString().toLowerCase();

      if (msg.contains('ticket no encontrado')) {
        _validationTitle = 'Ticket no encontrado';
        _validationStatus = 'Error';
        _validationColor = Colors.red;
      } else if (msg.contains('error al comunicar')) {
        _validationTitle = 'Error de servidor';
        _validationStatus = 'Intenta de nuevo';
        _validationColor = Colors.red;
      } else {
        _validationTitle = 'Error al validar ticket';
        _validationStatus = 'Error';
        _validationColor = Colors.red;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          qrResult = null;
        });
        controller.start();
      }
    }
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
                await _checkCameraPermission();
                if (mounted) setState(() {});
              },
              child: const Text('SOLICITAR PERMISO'),
            ),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            final String? code = capture.barcodes.first.rawValue;
            if (code != null && qrResult == null) {
              setState(() => qrResult = code);
              controller.stop();
              _validateTicket(code);
            }
          },
        ),
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 4),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }

  Widget _buildValidationCard(String title, String status, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.confirmation_num, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 20,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Chequear Tickets'),
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildScannerView(),
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading) const CircularProgressIndicator(),
              if (_validationTitle != null && _validationStatus != null)
                _buildValidationCard(
                  _validationTitle!,
                  _validationStatus!,
                  _validationColor ?? Colors.grey,
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
