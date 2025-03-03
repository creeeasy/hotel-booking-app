import 'package:flutter/material.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Divider(
        color: Colors.grey[400], // Suitable gray color
        thickness: 1.2,
        height: 20,
      ),
    );
  }
}
