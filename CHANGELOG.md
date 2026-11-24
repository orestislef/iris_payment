## 0.3.0

- The widgets moved from `package:flutter/material.dart` to [material_ui](https://pub.dev/packages/material_ui). Flutter 3.47 deprecated its own Material library for the material_ui package, and the two have different `Theme`, `Material` and `Card` types. An app on material_ui was not seen by the widgets: the invalid AFM text took its error color from a default theme, and `IrisPaymentCard` ignored the app's `CardThemeData`.
- This is breaking for apps still on `package:flutter/material.dart`: their theme is no longer read. Such apps stay on `iris_payment: ^0.2.0` until they move to material_ui.
- Minimum Dart is now 3.13 and minimum Flutter 3.47, what material_ui needs.
- No other change to the API or the output.

## 0.2.0

- `IrisQrCode` and `IrisPaymentCard` now take `data` as well as `afm`, so dynamic `IRISCOM` QR codes can be shown too. `afm` is no longer required (pass one of the two).
- `IrisPaymentCard` labels can be changed with `title`, `afmLabel`, `scanLabel` and `invalidText`, so the card can be shown in Greek. `scanLabel: null` hides the hint.
- `IrisQrCode` has `invalidText`, `semanticsLabel` and an `irisData` getter.
- New `toPngBytes()` on `IrisData` to export a QR as PNG for printing or sharing.
- New `AfmValidator.formValidator` for use with `TextFormField`.
- Minimum Flutter is now 3.27 (the package already used `Color.withValues`, which older versions don't have).
- Fixed doc examples that used an AFM with a wrong check digit.
- Shorter pubspec description so it fits on pub.dev.

## 0.1.1

- Updated `flutter_lints` dependency to `^6.0.0`.

## 0.1.0

- Initial release.
- AFM (Greek VAT number) validation with checksum verification.
- IRIS QR data string generation (`IRISTIN{AFM}` format).
- `IrisQrCode` Flutter widget with customizable size, colors, and error correction.
- Optional center logo overlay support.
- `IrisPaymentCard` ready-to-use payment card widget with business name display.
