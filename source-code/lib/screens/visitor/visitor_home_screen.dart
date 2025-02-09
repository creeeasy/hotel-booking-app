import 'package:flutter/material.dart';

class VisitorHomeScreen extends StatelessWidget {
  const VisitorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visitor Home"),
        backgroundColor: const Color(0xFF6C63FF), // Client button color
      ),
      body: const Center(
        child: Text(
          "Welcome to the Visitor Booking Page!",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
