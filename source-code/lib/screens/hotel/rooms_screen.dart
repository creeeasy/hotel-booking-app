import 'package:flutter/material.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
      ),
      body: const Center(
        child: Text(
          'View and manage hotel rooms here',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
