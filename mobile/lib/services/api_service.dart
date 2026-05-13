import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/estacion.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:8000";

  // 1. LISTAR ESTACIONES
  Future<List<Estacion>> fetchEstaciones() async {
    try {
      final token = await AuthService().getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/estaciones/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5)); // Evitar esperas infinitas 

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Estacion.fromJson(data)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      // Atrapamos el error para que la App no se cierre
      throw Exception('No se pudo conectar con SMAT. ¿Está el servidor activo?');
    }
  }

  // 2. CREAR ESTACIÓN
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

  // 3. ELIMINAR ESTACIÓN
  Future<bool> eliminarEstacion(int id) async {
    final token = await AuthService().getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/estaciones/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  // 4. EDITAR ESTACIÓN
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