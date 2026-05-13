import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/estacion.dart'; 
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'add_estacion.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Estacion>> futureEstaciones;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    futureEstaciones = apiService.fetchEstaciones();
  }

  Future<void> _refresh() async {
    setState(() {
      _cargarDatos();
    });
  }

  void _logout(BuildContext context) async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _mostrarDialogoEdicion(Estacion estacion) {
    final nombreCtrl = TextEditingController(text: estacion.nombre);
    final ubicacionCtrl = TextEditingController(text: estacion.ubicacion);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Estación"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
            TextField(controller: ubicacionCtrl, decoration: const InputDecoration(labelText: "Ubicación")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancelar")
          ),
          ElevatedButton(
            onPressed: () async {
              //Actualizamos la estación usando la API
              bool ok = await apiService.editarEstacion(estacion.id, nombreCtrl.text, ubicacionCtrl.text);
              if (ok) {
                if (!mounted) return;
                Navigator.pop(context); 
                _refresh();
              }
            },
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estaciones SMAT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      // --- SOLUCIÓN AL RETO: RefreshIndicator para deslizar hacia abajo ---
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Estacion>>(
          future: futureEstaciones,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay estaciones.'));
            }

            final estaciones = snapshot.data!;

            return ListView.builder(
              itemCount: estaciones.length,
              itemBuilder: (context, index) {
                final estacion = estaciones[index];

                // --- PASO 2: Swipe-to-Dismiss para eliminar ---
                return Dismissible(
                  key: Key(estacion.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    // Llamamos a la API para borrar
                    bool ok = await apiService.eliminarEstacion(estacion.id);
                    if (ok && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${estacion.nombre} eliminada"))
                      );
                    }
                  },
                  child: ListTile(
                    // --- SOLUCIÓN AL RETO: Lógica de Colores ---
                    // Nota: Si tu modelo Estacion no tiene 'ultimoValor', puedes usar un valor por defecto para que no marque error temporalmente
                    leading: const Icon(
                      Icons.sensors,
                      color: Colors.green, // Cambia la lógica aquí según tu modelo de datos
                    ),
                    title: Text(estacion.nombre),
                    subtitle: Text(estacion.ubicacion),
                    // Al tocar la estación, abre el diálogo de edición
                    onTap: () => _mostrarDialogoEdicion(estacion), 
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Espera a que vuelvas de la pantalla de crear para refrescar la lista
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEstacionScreen()),
          );
          if (result == true) {
            _refresh();
          }
        },
      ),
    );
  }
}