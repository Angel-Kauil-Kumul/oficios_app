import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/pdf_generator.dart';

class ListaOficiosScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const ListaOficiosScreen({required this.usuario, Key? key}) : super(key: key);

  @override
  _ListaOficiosScreenState createState() => _ListaOficiosScreenState();
}

class _ListaOficiosScreenState extends State<ListaOficiosScreen> {
  List<dynamic> oficios = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarOficios();
  }

  void cargarOficios() async {
    setState(() => cargando = true);

    final data = await ApiService.obtenerOficios(widget.usuario['ID_User']);

    setState(() {
      oficios = data;
      cargando = false;
    });
  }

  void cerrarSesion() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Oficios'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: cerrarSesion,
              icon: Icon(Icons.logout),
              label: Text('Cerrar Sesión', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: cargando
                  ? Center(child: CircularProgressIndicator())
                  : oficios.isEmpty
                  ? Center(child: Text('No tienes oficios registrados'))
                  : ListView.builder(
                itemCount: oficios.length,
                itemBuilder: (context, index) {
                  final oficio = oficios[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    elevation: 3,
                    child: ListTile(
                      title: Text('Oficio #${oficio['numero_oficio']}'),
                      subtitle: Text(oficio['asunto']),
                      trailing: IconButton(
                        icon: Icon(Icons.picture_as_pdf),
                        tooltip: 'Generar PDF',
                        onPressed: () {
                          PDFGenerator.generarYMostrarPDF(oficio);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}




