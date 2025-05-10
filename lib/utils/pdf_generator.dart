import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFGenerator {
  static Future<void> generarYMostrarPDF(Map<String, dynamic> oficio) async {
    final pdf = pw.Document();

    // Cargar fuentes
    final font = await pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final boldFont = await pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
    final italicFont = await pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Italic.ttf'));

    // Cargar imágenes
    final encabezado = pw.MemoryImage(
      (await rootBundle.load('assets/encabezado.png')).buffer.asUint8List(),
    );
    final pie = pw.MemoryImage(
      (await rootBundle.load('assets/piedepagina.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          children: [
            pw.Image(encabezado),
            pw.SizedBox(height: 20),

            // Encabezado con fecha, número de oficio y asunto
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 30),
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Tizimín, Yucatán, ${formatearFecha(oficio['fecha_emision'])}',
                      style: pw.TextStyle(font: font),
                    ),
                    pw.Text('Oficio No. ${oficio['numero_oficio']}', style: pw.TextStyle(font: font)),
                    pw.Text('Asunto: ${oficio['asunto']}', style: pw.TextStyle(font: font)),
                  ],
                ),
              ),
            ),

            pw.SizedBox(height: 20),

            // Cuerpo del documento
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 30),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Aquí se usa el destinatario si está disponible
                  pw.Text(
                    (oficio['destinatario']?.toString().trim().isNotEmpty ?? false)
                        ? oficio['destinatario']
                        : 'A QUIEN CORRESPONDA',
                    style: pw.TextStyle(font: boldFont),
                  ),
                  pw.Text('PRESENTE', style: pw.TextStyle(font: font)),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    oficio['contenido'] ?? '',
                    style: pw.TextStyle(font: font),
                    textAlign: pw.TextAlign.justify,
                  ),
                  pw.SizedBox(height: 30),
                  pw.Text('A T E N T A M E N T E', style: pw.TextStyle(font: boldFont)),
                  pw.Text('Excelencia en Educación Tecnológica.', style: pw.TextStyle(font: italicFont)),
                  pw.Text('Ciencia y Tecnología al Servicio del Hombre', style: pw.TextStyle(font: italicFont)),
                  pw.SizedBox(height: 30),
                  pw.Text(oficio['firma'] ?? 'Nombre', style: pw.TextStyle(font: boldFont)),
                  pw.Text(oficio['cargo'] ?? 'Cargo', style: pw.TextStyle(font: font)),

                  if ((oficio['ccp'] ?? '').toString().trim().isNotEmpty) ...[
                    pw.SizedBox(height: 20),
                    pw.Text('c.c.p. ${oficio['ccp']}', style: pw.TextStyle(font: italicFont, fontSize: 10)),
                  ],
                ],
              ),
            ),

            pw.Spacer(),
            pw.Image(pie),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // 👉 Función para convertir de '2025-05-02' a '02/05/2025'
  static String formatearFecha(String fechaISO) {
    try {
      final partes = fechaISO.split('-');
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    } catch (_) {
      return fechaISO;
    }
  }
}




