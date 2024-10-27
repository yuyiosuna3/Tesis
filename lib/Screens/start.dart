// start.dart
import 'package:flutter/material.dart';

class Start extends StatelessWidget {
  const Start({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Page'),
      ),
      body: const Center(
        child: Text(
          'Bienvenido a la página de inicio',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

