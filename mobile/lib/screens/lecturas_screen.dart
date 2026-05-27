import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LecturasScreen extends StatefulWidget {
  const LecturasScreen({Key? key}) : super(key: key);

  @override
  State<LecturasScreen> createState() => _LecturasScreenState();
}

class _LecturasScreenState extends State<LecturasScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _lecturas = [];
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarLecturas();
    // Revisa el backend de forma automática cada 2 segundos
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) => _cargarLecturas());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Limpia el temporizador
    super.dispose();
  }

  Future<void> _cargarLecturas() async {
    try {
      final datos = await _apiService.fetchLecturas();
      setState(() {
        // Ordenamos la lista para ver la lectura más reciente arriba
        _lecturas = datos.reversed.toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error al actualizar datos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoreo SMAT - Telemetría IoT'),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lecturas.isEmpty
              ? const Center(child: Text('Esperando métricas del sensor...'))
              : ListView.builder(
                  itemCount: _lecturas.length,
                  itemBuilder: (context, index) {
                    final lectura = _lecturas[index];
                    final double valorFlujo = double.tryParse(lectura['valor'].toString()) ?? 0.0;
                    
                    // Alerta
                    final bool esAlerta = valorFlujo > 70.0;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      // INTERFAZ REACTIVA: Rojo si es alerta, Verde si es normal
                      color: esAlerta ? Colors.red.shade100 : Colors.green.shade100,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: esAlerta ? Colors.red.shade700 : Colors.green.shade700,
                          width: esAlerta ? 2.5 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          esAlerta ? Icons.warning_amber_rounded : Icons.water_drop,
                          color: esAlerta ? Colors.red.shade700 : Colors.green.shade700,
                          size: 32,
                        ),
                        title: Text(
                          'Nivel: $valorFlujo cm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: esAlerta ? Colors.red.shade900 : Colors.green.shade900,
                          ),
                        ),
                        subtitle: Text(
                          esAlerta ? '¡ALERTA DE DESBORDE!' : 'Estado del Río: Normal',
                          style: TextStyle(
                            fontWeight: esAlerta ? FontWeight.bold : FontWeight.normal,
                            color: esAlerta ? Colors.red.shade700 : Colors.black54,
                          ),
                        ),
                        trailing: Text(
                          'Estación #${lectura['estacion_id']}',
                          style: const TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}