import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/estacion.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:8000";

  // 1. EL MÉTODO PARA OBTENER LA LISTA DE ESTACIONES
  Future<List<Estacion>> fetchEstaciones() async {
    final token = await AuthService().getToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/estaciones/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Token de seguridad
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Estacion.fromJson(data)).toList();
    } else {
      throw Exception('Fallo al cargar las estaciones');
    }
  }

  // 2. EL MÉTODO PARA CREAR UNA NUEVA ESTACIÓN
  Future<bool> crearEstacion(String nombre, String ubicacion) async {
    final token = await AuthService().getToken();
    
    final response = await http.post(
      Uri.parse('$baseUrl/estaciones/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'nombre': nombre, 'ubicacion': ubicacion}),
    );
    
    return response.statusCode == 200;
  }
  // 3. Eliminar una estación
  Future<bool> eliminarEstacion(int id) async {
    final token = await AuthService().getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/estaciones/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  // 4. Actualizar una estación existente
  Future<bool> editarEstacion(int id, String nombre, String ubicacion) async {
    final token = await AuthService().getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/estaciones/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'nombre': nombre, 'ubicacion': ubicacion}),
    );
    return response.statusCode == 200;
  }

}