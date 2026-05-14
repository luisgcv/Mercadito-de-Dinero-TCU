import 'dart:ui' as ui;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';

import '../models/producto.dart';

class PdfExportService {
  Future<void> exportarCatalogoPdf(List<Producto> productos) async {
    final pdf = pw.Document();

    // Generar datos del PDF (nombre, precio, QR)
    final productosConQr = <Map<String, dynamic>>[];

    for (final producto in productos) {
      final qrImage = await _generarQrImage(producto.codigoQr);
      productosConQr.add({
        'nombre': producto.nombre,
        'precio': producto.precio,
        'qr': qrImage,
      });
    }

    // Crear página del catálogo
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        header: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Column(
              children: [
                pw.Text(
                  'CATÁLOGO DE PRODUCTOS',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Mercadito - ${DateTime.now().toString().split(' ')[0]}',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(2),
              },
              children: [
                // Encabezado de tabla
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Producto',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Precio',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Código QR',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                // Filas de productos
                ...productosConQr.map(
                  (item) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          item['nombre'] as String,
                          maxLines: 2,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'CRC ${(item['precio'] as double).toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Column(
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(10),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 1.5,
                                ),
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Image(
                                item['qr'] as pw.ImageProvider,
                                width: 65,
                                height: 65,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Escanee para ver\ndetalles del producto',
                              style: pw.TextStyle(
                                fontSize: 7,
                                color: PdfColors.grey600,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    // Mostrar diálogo de impresión/guardado
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'catalogo_productos_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  Future<pw.ImageProvider> _generarQrImage(String data) async {
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
      color: const ui.Color(0xFF000000),
      emptyColor: const ui.Color(0xFFFFFFFF),
    );

    final byteData = await painter.toImageData(
      256,
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw Exception('No se pudo generar la imagen QR');
    }

    return pw.MemoryImage(byteData.buffer.asUint8List());
  }
}
