import 'package:flutter/material.dart';
import '../models/empleado_model.dart';
import '../models/departamento_model.dart';
import '../services/api_service.dart';
import '../utils/pdf_generator.dart'; // Solo si usas PDF

class CrearOficioScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;
  const CrearOficioScreen({required this.usuario, Key? key}) : super(key: key);

  @override
  _CrearOficioScreenState createState() => _CrearOficioScreenState();
}

class _CrearOficioScreenState extends State<CrearOficioScreen> {
  final numeroController = TextEditingController();
  final fechaController = TextEditingController();
  String fechaFormateada = '';
  final asuntoController = TextEditingController();
  final contenidoController = TextEditingController();
  final firmaController = TextEditingController();
  final cargoController = TextEditingController();
  final destinatarioManualController = TextEditingController();

  List<Departamento> departamentos = [];
  List<Empleado> empleados = [];

  int? departamentoSeleccionado;
  int? empleadoSeleccionado;
  bool usarTextoLibre = true;

  @override
  void initState() {
    super.initState();
    cargarDepartamentos();
    cargarEmpleados();
  }

  void cargarDepartamentos() async {
    final data = await ApiService.obtenerDepartamentos();
    setState(() {
      departamentos = data;
    });
  }

  void cargarEmpleados() async {
    final data = await ApiService.obtenerEmpleados();
    setState(() {
      empleados = data;
    });
  }

  void crearOficio() async {
    final nombreCCP = departamentoSeleccionado != null
        ? departamentos.firstWhere((dep) => dep.id == departamentoSeleccionado).nombre
        : null;

    final destinatario = usarTextoLibre
        ? destinatarioManualController.text.trim()
        : empleados.firstWhere((emp) => emp.id == empleadoSeleccionado).nombre;

    final datos = {
      'numero_oficio': numeroController.text.trim(),
      'fecha_emision': fechaFormateada,
      'asunto': asuntoController.text.trim(),
      'contenido': contenidoController.text.trim(),
      'firma': firmaController.text.trim(),
      'cargo': cargoController.text.trim(),
      'remitente_id': widget.usuario['ID_User'],
      'departamento_id': departamentoSeleccionado,
      'ccp': nombreCCP,
      'destinatario': destinatario,
      'estatus': 'Pendiente',
    };

    final exito = await ApiService.crearOficio(datos);

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Oficio creado correctamente')),
      );
      await PDFGenerator.generarYMostrarPDF(datos); // si lo usas
      numeroController.clear();
      fechaController.clear();
      asuntoController.clear();
      contenidoController.clear();
      firmaController.clear();
      cargoController.clear();
      destinatarioManualController.clear();
      setState(() {
        departamentoSeleccionado = null;
        empleadoSeleccionado = null;
        usarTextoLibre = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al crear el oficio')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Oficio'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(controller: numeroController, decoration: InputDecoration(labelText: 'Número de oficio')),
            TextFormField(
              controller: fechaController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Fecha de emisión'),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  locale: const Locale('es', ''),
                );
                if (picked != null) {
                  final String fechaVisible = "${picked.day.toString().padLeft(2, '0')}/"
                      "${picked.month.toString().padLeft(2, '0')}/"
                      "${picked.year}";
                  fechaFormateada = "${picked.year}-"
                      "${picked.month.toString().padLeft(2, '0')}-"
                      "${picked.day.toString().padLeft(2, '0')}";
                  setState(() {
                    fechaController.text = fechaVisible;
                  });
                }
              },
            ),
            TextField(controller: asuntoController, decoration: InputDecoration(labelText: 'Asunto')),
            TextField(controller: contenidoController, decoration: InputDecoration(labelText: 'Contenido'), maxLines: 5),
            TextField(controller: firmaController, decoration: InputDecoration(labelText: 'Nombre de quien firma')),
            TextField(controller: cargoController, decoration: InputDecoration(labelText: 'Cargo')),
            SizedBox(height: 20),
            Text('Destinatario:', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text('Escribir manualmente'),
                    value: true,
                    groupValue: usarTextoLibre,
                    onChanged: (value) => setState(() => usarTextoLibre = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text('Seleccionar empleado'),
                    value: false,
                    groupValue: usarTextoLibre,
                    onChanged: (value) => setState(() => usarTextoLibre = value!),
                  ),
                ),
              ],
            ),
            usarTextoLibre
                ? TextField(
              controller: destinatarioManualController,
              decoration: InputDecoration(labelText: 'Destinatario'),
            )
                : DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Selecciona un empleado'),
              items: empleados.map<DropdownMenuItem<int>>((emp) {
                return DropdownMenuItem<int>(
                  value: emp.id,
                  child: Text(emp.nombre),
                );
              }).toList(),
              value: empleadoSeleccionado,
              onChanged: (value) {
                setState(() {
                  empleadoSeleccionado = value;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Departamento destino (CCP)'),
              items: departamentos.map<DropdownMenuItem<int>>((dep) {
                return DropdownMenuItem<int>(
                  value: dep.id,
                  child: Text(dep.nombre),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  departamentoSeleccionado = value;
                });
              },
              value: departamentoSeleccionado,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: crearOficio, child: Text('Crear Oficio')),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/listaOficios', arguments: widget.usuario),
              child: Text('Ver mis oficios'),
            ),
          ],
        ),
      ),
    );
  }
}


