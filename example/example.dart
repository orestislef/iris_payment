import 'package:material_ui/material_ui.dart';
import 'package:iris_payment/iris_payment.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('IRIS Payment Example')),
        body: const Center(child: IrisExample()),
      ),
    );
  }
}

class IrisExample extends StatefulWidget {
  const IrisExample({super.key});

  @override
  State<IrisExample> createState() => _IrisExampleState();
}

class _IrisExampleState extends State<IrisExample> {
  final _controller = TextEditingController(text: '090000045');

  // A dynamic QR normally comes from your payment gateway.
  final _gatewayQr =
      IrisData.fromTransactionId('52bb5e73-2ebd-4299-9ccf-e9714b9873fc');

  int? _pngSize;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _exportPng() async {
    final data = IrisData.tryFromAfm(_controller.text);
    if (data == null) return;
    final bytes = await data.toPngBytes(size: 1024);
    // Save, print or share the bytes here.
    setState(() => _pngSize = bytes.length);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextFormField(
            controller: _controller,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: AfmValidator.formValidator,
            decoration: const InputDecoration(
              labelText: 'AFM (Tax ID)',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),

          // Static QR from the AFM
          IrisQrCode(
            afm: _controller.text,
            size: 250,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _exportPng,
            child: const Text('Export PNG'),
          ),
          if (_pngSize != null) Text('PNG ready, $_pngSize bytes'),
          const SizedBox(height: 32),

          // Payment card with Greek labels
          IrisPaymentCard(
            afm: _controller.text,
            businessName: 'Καφέ Το Στέκι',
            title: 'Πληρωμή με IRIS',
            afmLabel: 'ΑΦΜ',
            scanLabel: 'Σκανάρετε για πληρωμή',
            invalidText: 'Μη έγκυρο ΑΦΜ',
            qrSize: 200,
          ),
          const SizedBox(height: 32),

          // Dynamic QR from a payment gateway
          IrisPaymentCard(
            data: _gatewayQr,
            businessName: 'My Online Shop',
            qrSize: 200,
          ),
        ],
      ),
    );
  }
}
