import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QRCodePage(),
    );
  }
}

class QRCodePage extends StatelessWidget {
  // URL to form for adding users to the class
  final String formURL = "https://example.com";

  const QRCodePage({super.key});

  // Theme
  static const Color primaryColor = Color.fromARGB(255, 255, 100, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('QR Code Generator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QrImageView(
              data: formURL,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Scan the QR code to join the class!',
              style: TextStyle(fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
