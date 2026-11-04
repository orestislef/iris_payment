import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'iris_data.dart';

/// Renders [IrisData] to an image without putting a widget on screen.
///
/// ```dart
/// final bytes = await IrisData.fromAfm('090000045').toPngBytes(size: 1024);
/// File('iris.png').writeAsBytesSync(bytes);
/// ```
extension IrisQrExport on IrisData {
  /// Draws the QR code and returns it as PNG bytes.
  ///
  /// Useful for printing on receipts, saving to a file or sharing.
  ///
  /// [size] is the full image width and height in pixels. [margin] is the
  /// blank space kept around the code on every side, which scanners need to
  /// find it. Dark modules on a light background scan most reliably, so
  /// keep the default colors unless you have a reason not to.
  ///
  /// Throws [ArgumentError] if [size] is not larger than twice [margin].
  Future<Uint8List> toPngBytes({
    int size = 512,
    int margin = 32,
    Color foregroundColor = const Color(0xFF000000),
    Color backgroundColor = const Color(0xFFFFFFFF),
    int errorCorrectionLevel = QrErrorCorrectLevel.H,
  }) async {
    if (margin < 0) {
      throw ArgumentError.value(margin, 'margin', 'must not be negative');
    }
    if (size <= margin * 2) {
      throw ArgumentError.value(
        size,
        'size',
        'must be larger than twice the margin ($margin)',
      );
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final full = size.toDouble();
    canvas.drawRect(
      Rect.fromLTWH(0, 0, full, full),
      Paint()..color = backgroundColor,
    );

    final inner = full - margin * 2;
    canvas.translate(margin.toDouble(), margin.toDouble());
    QrPainter(
      data: qrString,
      version: QrVersions.auto,
      errorCorrectionLevel: errorCorrectionLevel,
      gapless: true,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: foregroundColor,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: foregroundColor,
      ),
    ).paint(canvas, Size(inner, inner));

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw StateError('Could not encode the QR code as PNG');
      }
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
      picture.dispose();
    }
  }
}
