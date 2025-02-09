import 'package:flutter/material.dart';

class HotelHomeView extends StatelessWidget {
  const HotelHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hotel Dashboard"),
        backgroundColor: const Color(0xFFC84648), // Theme primary color
      ),
      body: const Center(
        child: Text(
          "Welcome to the Hotel Dashboard!",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
