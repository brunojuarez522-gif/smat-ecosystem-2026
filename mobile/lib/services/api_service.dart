import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/estacion.dart'; // ← Asegúrate de que el nombre de este archivo coincida con el tuyo

class ApiService {
  final String baseUrl = "http://10.0.2.2:8000";

  // 1. EL MÉTODO QUE FALTABA (Para leer las estaciones)
  Future<List<Estacion>> fetchEstaciones() async {
    final token = await AuthService().getToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/estaciones/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Añadimos el token de seguridad
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Estacion.fromJson(data)).toList();
    } else {
      throw Exception('Fallo al cargar las estaciones');
    }
  }

  // 2. EL MÉTODO NUEVO DEL LABORATORIO 6.2 (Para crear)
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
}