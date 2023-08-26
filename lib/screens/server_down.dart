import 'package:flutter/material.dart';

class ServerPage extends StatelessWidget {
  const ServerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Down'),
      ),
      body: const Center(
        child: Text('The server is currently down 😔'),
      ),
    );
  }
}
