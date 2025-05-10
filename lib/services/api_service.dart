import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/empleado_model.dart';
import '../models/departamento_model.dart';

class ApiService {
  static const baseUrl = 'http://localhost:3000/api';

  static Future<Map<String, dynamic>?> login(String nombre, String contrasena) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nombre': nombre, 'contrasena': contrasena}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['usuario'];
    } else {
      return null;
    }
  }

  static Future<bool> crearOficio(Map<String, dynamic> datos) async {
    final url = Uri.parse('$baseUrl/oficios');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );

    return response.statusCode == 201;
  }

  static Future<List<dynamic>> obtenerOficios(int usuarioId) async {
    final url = Uri.parse('$baseUrl/oficios/usuario/$usuarioId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  static Future<List<Empleado>> obtenerEmpleados() async {
    final url = Uri.parse('$baseUrl/empleados');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Empleado.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  static Future<List<Departamento>> obtenerDepartamentos() async {
    final url = Uri.parse('$baseUrl/departamentos');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Departamento.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}

