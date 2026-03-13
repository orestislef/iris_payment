import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'iris_data.dart';

/// A Flutter widget that renders an IRIS payment QR code.
///
/// Displays a QR code containing the IRIS payment string for the given AFM.
/// Supports customizable size, colors, and an optional center logo.
///
/// ```dart
/// IrisQrCode(
///   afm: '123456789',
///   size: 250,
/// )
/// ```
class IrisQrCode extends StatelessWidget {
  /// The AFM (Greek VAT number) to encode.
  final String afm;

  /// Size of the QR code in logical pixels. Default: 200.
  final double size;

  /// Foreground color of the QR modules. Default: black.
  final Color foregroundColor;

  /// Background color. Default: white.
  final Color backgroundColor;

  /// QR error correction level. Default: high (H).
  ///
  /// High error correction allows up to ~30% of the QR code to be
  /// obscured (e.g., by a logo) while remaining scannable.
  final int errorCorrectionLevel;

  /// Optional widget to display in the center of the QR code.
  ///
  /// Typically used for the IRIS logo or a business logo.
  /// The logo is placed over the QR code with a white padding.
  final Widget? logo;

  /// Size of the logo area. Default: 60.
  final double logoSize;

  /// Padding around the logo. Default: 4.
  final double logoPadding;

  /// Border radius of the QR code container. Default: 8.
  final double borderRadius;

  /// Whether to show a border around the QR code. Default: true.
  final bool showBorder;

  /// Border color. Default: grey[300].
  final Color? borderColor;

  const IrisQrCode({
    super.key,
    required this.afm,
    this.size = 200,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.errorCorrectionLevel = QrErrorCorrectLevel.H,
    this.logo,
    this.logoSize = 60,
    this.logoPadding = 4,
    this.borderRadius = 8,
    this.showBorder = true,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final irisData = IrisData.tryFromAfm(afm);
    if (irisData == null) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            'Invalid AFM',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: borderColor ?? Colors.grey.shade300,
                width: 1,
              )
            : null,
      ),
      padding: const EdgeInsets.all(8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          QrImageView(
            data: irisData.qrString,
            version: QrVersions.auto,
            size: size - 16,
            errorCorrectionLevel: errorCorrectionLevel,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: foregroundColor,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: foregroundColor,
            ),
            backgroundColor: backgroundColor,
          ),
          if (logo != null)
            Container(
              width: logoSize + logoPadding * 2,
              height: logoSize + logoPadding * 2,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.all(logoPadding),
              child: SizedBox(
                width: logoSize,
                height: logoSize,
                child: logo,
              ),
            ),
        ],
      ),
    );
  }
}

/// A ready-to-use IRIS payment card widget.
///
/// Displays the QR code with an optional business name and AFM label.
/// Useful for printing or displaying at a point of sale.
///
/// ```dart
/// IrisPaymentCard(
///   afm: '123456789',
///   businessName: 'My Shop',
/// )
/// ```
class IrisPaymentCard extends StatelessWidget {
  /// The AFM to encode.
  final String afm;

  /// Business name to display above the QR code.
  final String? businessName;

  /// Size of the QR code. Default: 200.
  final double qrSize;

  /// Foreground color of the QR modules.
  final Color foregroundColor;

  /// Background color of the card.
  final Color backgroundColor;

  /// Optional logo widget for the QR center.
  final Widget? logo;

  /// Logo size. Default: 60.
  final double logoSize;

  /// Whether to show the AFM text below the QR code. Default: true.
  final bool showAfm;

  /// Card elevation. Default: 2.
  final double elevation;

  /// Card border radius. Default: 12.
  final double borderRadius;

  const IrisPaymentCard({
    super.key,
    required this.afm,
    this.businessName,
    this.qrSize = 200,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.logo,
    this.logoSize = 60,
    this.showAfm = true,
    this.elevation = 2,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // IRIS label
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code_2, size: 20, color: foregroundColor),
                const SizedBox(width: 6),
                Text(
                  'IRIS Payment',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: foregroundColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),

            if (businessName != null) ...[
              const SizedBox(height: 8),
              Text(
                businessName!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: foregroundColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 12),

            // QR code
            IrisQrCode(
              afm: afm,
              size: qrSize,
              foregroundColor: foregroundColor,
              backgroundColor: backgroundColor,
              logo: logo,
              logoSize: logoSize,
              showBorder: false,
            ),

            if (showAfm) ...[
              const SizedBox(height: 8),
              Text(
                'AFM: ${_formatAfm(afm)}',
                style: TextStyle(
                  fontSize: 13,
                  color: foregroundColor.withValues(alpha: 0.5),
                  fontFamily: 'monospace',
                  letterSpacing: 1.5,
                ),
              ),
            ],

            const SizedBox(height: 4),
            Text(
              'Scan to pay',
              style: TextStyle(
                fontSize: 12,
                color: foregroundColor.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAfm(String afm) {
    final cleaned = afm.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.length == 9) {
      return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
    }
    return cleaned;
  }
}
