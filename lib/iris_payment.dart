/// Greek IRIS payment QR code generator.
///
/// Validate AFM (Greek VAT/Tax ID), generate IRIS-standard QR data,
/// and render payment QR codes with customizable styles and logo overlay.
///
/// ```dart
/// import 'package:iris_payment/iris_payment.dart';
///
/// // Validate an AFM
/// AfmValidator.isValid('123456789'); // true or false
///
/// // Generate QR data
/// final data = IrisData.fromAfm('123456789');
/// print(data.qrString); // "IRISTIN123456789"
///
/// // Use the widget
/// IrisQrCode(afm: '123456789', size: 250)
/// ```
library;

export 'src/afm_validator.dart';
export 'src/iris_data.dart';
export 'src/iris_qr_widget.dart';
