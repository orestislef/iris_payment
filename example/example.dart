import 'package:flutter/material.dart';
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
  final _controller = TextEditingController(text: '123456789');
  String? _error;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // AFM input
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'AFM (Tax ID)',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              final result = AfmValidator.validate(value);
              setState(() {
                _error = result.isValid ? null : result.message;
              });
            },
          ),
          const SizedBox(height: 24),

          // Simple QR code
          IrisQrCode(
            afm: _controller.text,
            size: 250,
          ),
          const SizedBox(height: 32),

          // Full payment card
          IrisPaymentCard(
            afm: _controller.text,
            businessName: 'My Coffee Shop',
            qrSize: 200,
          ),
        ],
      ),
    );
  }
}
