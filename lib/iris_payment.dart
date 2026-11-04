/// Greek IRIS payment QR code generator.
///
/// Validate AFM (Greek VAT/Tax ID), generate IRIS-standard QR data,
/// render payment QR codes with customizable styles and logo overlay,
/// and export them as PNG.
///
/// ```dart
/// import 'package:iris_payment/iris_payment.dart';
///
/// // Validate an AFM
/// AfmValidator.isValid('090000045'); // true
///
/// // Generate QR data
/// final data = IrisData.fromAfm('090000045');
/// print(data.qrString); // "IRISTIN090000045"
///
/// // Use the widget
/// IrisQrCode(afm: '090000045', size: 250)
/// ```
library;

export 'src/afm_validator.dart';
export 'src/iris_data.dart';
export 'src/iris_qr_export.dart';
export 'src/iris_qr_widget.dart';
