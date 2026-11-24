import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iris_payment/iris_payment.dart';
import 'package:qr_flutter/qr_flutter.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

/// The string encoded by the single [IrisQrCode] on screen, after
/// checking that a QR is actually drawn.
String? _qrDataIn(WidgetTester tester) {
  expect(find.byType(QrImageView), findsOneWidget);
  return tester.widget<IrisQrCode>(find.byType(IrisQrCode)).irisData?.qrString;
}

/// Every [name] widget in the tree is material_ui's [type]. Counted by name
/// so a widget of `package:flutter/material.dart` with the same name, which
/// this file cannot even refer to, would show up as a difference.
void _onlyMaterialUi(WidgetTester tester) {
  final types = <String, Type>{
    'MaterialApp': MaterialApp,
    'Theme': Theme,
    'Scaffold': Scaffold,
    'Material': Material,
    'Card': Card,
  };
  for (final MapEntry(key: name, value: type) in types.entries) {
    final byName = find
        .byWidgetPredicate((w) => w.runtimeType.toString() == name)
        .evaluate()
        .length;
    expect(
      find.byType(type).evaluate().length,
      byName,
      reason: "a $name that is not material_ui's",
    );
  }
}

void main() {
  group('IrisQrCode', () {
    testWidgets('renders static QR for a valid AFM', (tester) async {
      await tester.pumpWidget(_wrap(const IrisQrCode(afm: '090-000-045')));
      expect(_qrDataIn(tester), 'IRISTIN090000045');
    });

    testWidgets('renders dynamic QR from data', (tester) async {
      final tx = IrisData.fromTransactionId(
        '52bb5e73-2ebd-4299-9ccf-e9714b9873fc',
      );
      await tester.pumpWidget(_wrap(IrisQrCode(data: tx)));
      expect(_qrDataIn(tester), 'IRISCOM52bb5e73-2ebd-4299-9ccf-e9714b9873fc');
    });

    testWidgets('data takes priority over afm', (tester) async {
      final tx = IrisData.fromTransactionId('abc');
      await tester.pumpWidget(_wrap(IrisQrCode(afm: '090000045', data: tx)));
      expect(_qrDataIn(tester), 'IRISCOMabc');
    });

    testWidgets('shows invalid text for a bad AFM', (tester) async {
      await tester.pumpWidget(
        _wrap(const IrisQrCode(afm: '123456789', invalidText: 'Bad AFM')),
      );
      expect(find.byType(QrImageView), findsNothing);
      expect(find.text('Bad AFM'), findsOneWidget);
    });

    test('asserts when neither afm nor data is given', () {
      expect(() => IrisQrCode(), throwsAssertionError);
    });
  });

  group('IrisPaymentCard', () {
    testWidgets('default labels', (tester) async {
      await tester.pumpWidget(
        _wrap(const IrisPaymentCard(afm: '090000045', businessName: 'Shop')),
      );
      expect(find.text('IRIS Payment'), findsOneWidget);
      expect(find.text('Shop'), findsOneWidget);
      expect(find.text('AFM: 090 000 045'), findsOneWidget);
      expect(find.text('Scan to pay'), findsOneWidget);
    });

    testWidgets('custom Greek labels', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const IrisPaymentCard(
            afm: '090000045',
            title: 'Πληρωμή με IRIS',
            afmLabel: 'ΑΦΜ',
            scanLabel: 'Σκανάρετε για πληρωμή',
          ),
        ),
      );
      expect(find.text('Πληρωμή με IRIS'), findsOneWidget);
      expect(find.text('ΑΦΜ: 090 000 045'), findsOneWidget);
      expect(find.text('Σκανάρετε για πληρωμή'), findsOneWidget);
    });

    testWidgets('scanLabel null hides the hint', (tester) async {
      await tester.pumpWidget(
        _wrap(const IrisPaymentCard(afm: '090000045', scanLabel: null)),
      );
      expect(find.text('Scan to pay'), findsNothing);
    });

    testWidgets('dynamic data hides the AFM line', (tester) async {
      await tester.pumpWidget(
        _wrap(IrisPaymentCard(data: IrisData.fromTransactionId('abc'))),
      );
      expect(_qrDataIn(tester), 'IRISCOMabc');
      expect(find.textContaining('AFM'), findsNothing);
    });
  });

  group('toPngBytes', () {
    testWidgets('returns a PNG of the requested size', (tester) async {
      final bytes = await tester.runAsync(
        () => IrisData.fromAfm('090000045').toPngBytes(size: 300),
      );
      expect(bytes, isNotNull);
      // PNG signature
      expect(bytes!.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);
      // IHDR width and height, big endian
      final header = bytes.buffer.asByteData(bytes.offsetInBytes);
      expect(header.getUint32(16), 300);
      expect(header.getUint32(20), 300);
    });

    test('rejects a size smaller than the margins', () {
      final data = IrisData.fromAfm('090000045');
      expect(() => data.toPngBytes(size: 60, margin: 32), throwsArgumentError);
      expect(() => data.toPngBytes(margin: -1), throwsArgumentError);
    });
  });

  // This file imports material_ui only, so there is no Theme or Material of
  // the framework's in these trees.
  group('material_ui', () {
    const error = Color(0xFF8E24AA);
    const shadow = Color(0xFF00695C);
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)
          .copyWith(error: error),
      cardTheme: const CardThemeData(
        shadowColor: shadow,
        margin: EdgeInsets.all(20),
      ),
    );

    Widget app(Widget child, {ThemeData? theme}) => MaterialApp(
      theme: theme,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

    testWidgets('the QR and the card build with no framework Material', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(const IrisPaymentCard(afm: '090000045', businessName: 'Shop')),
      );
      expect(tester.takeException(), isNull);
      _onlyMaterialUi(tester);
      expect(_qrDataIn(tester), 'IRISTIN090000045');
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('the invalid text takes the error color of the theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(const IrisQrCode(afm: '123456789'), theme: theme),
      );
      _onlyMaterialUi(tester);
      expect(tester.widget<Text>(find.text('Invalid AFM')).style?.color, error);

      final dark = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      );
      await tester.pumpWidget(
        app(const IrisQrCode(afm: '123456789'), theme: dark),
      );
      // MaterialApp animates from one theme to the next.
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.text('Invalid AFM')).style?.color,
        dark.colorScheme.error,
      );
    });

    testWidgets("the card follows the theme's CardThemeData", (tester) async {
      await tester.pumpWidget(
        app(const IrisPaymentCard(afm: '090000045'), theme: theme),
      );
      _onlyMaterialUi(tester);
      final material = tester.widget<Material>(
        find.descendant(of: find.byType(Card), matching: find.byType(Material)),
      );
      expect(material.shadowColor, shadow);
      expect(
        tester
            .widget<Padding>(
              find
                  .descendant(
                    of: find.byType(Card),
                    matching: find.byType(Padding),
                  )
                  .first,
            )
            .padding,
        const EdgeInsets.all(20),
      );
    });
  });
}
