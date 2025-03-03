// ignore_for_file: prefer_const_constructors

import 'package:fatiel/models/room.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RoomCardWidget extends StatefulWidget {
  final Room room;

  final bool isSelected;
  final VoidCallback jumpToIndex;

  const RoomCardWidget({
    super.key,
    required this.room,
    required this.jumpToIndex,
    required this.isSelected,
  });

  @override
  State<RoomCardWidget> createState() => _RoomCardWidgetState();
}

class _RoomCardWidgetState extends State<RoomCardWidget> {
  late Room room;
  late bool isSelected;
  late VoidCallback jumpToIndex;
  @override
  void initState() {
    room = widget.room;
    jumpToIndex = widget.jumpToIndex;
    isSelected = widget.isSelected;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: jumpToIndex,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: const EdgeInsets.all(12),
        width: 220,
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: room.images.isNotEmpty
                  ? Image.network(
                      room.images[0],
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              room.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.userGroup,
                        size: 14, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Text("${room.capacity} Guests",
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.dollarSign,
                        size: 14, color: Colors.green),
                    const SizedBox(width: 2),
                    Text("${room.pricePerNight.toStringAsFixed(2)} / night",
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (room.amenities.isNotEmpty)
              Wrap(
                spacing: 8,
                children: room.amenities.take(2).map((amenity) {
                  return Chip(
                    label: Text(
                      amenity,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blueGrey[50],
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  );
                }).toList(),
              ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      room.availability.isAvailable ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  room.availability.isAvailable ? "Available" : "Unavailable",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
