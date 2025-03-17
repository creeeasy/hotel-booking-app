import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/widgets/hotel_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HotelsListWidget extends StatefulWidget {
  final List<Hotel> hotels;

  const HotelsListWidget({super.key, required this.hotels});

  @override
  State<HotelsListWidget> createState() => _HotelsListWidgetState();
}

class _HotelsListWidgetState extends State<HotelsListWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.hotel,
                      color: Colors.blueAccent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Hotels Found",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${widget.hotels.length} hotels",
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: VisitorThemeColors.skyBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: widget.hotels.length,
              padding: const EdgeInsets.only(top: 8),
              itemBuilder: (context, index) {
                final animation = Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      (1 / widget.hotels.length) * index,
                      1.0,
                      curve: Curves.easeInOut,
                    ),
                  ),
                );

                return FadeTransition(
                  opacity: animation,
                  child: HotelRowOneWidget(
                    hotelId: widget.hotels[index].id,
                    animation: animation,
                    animationController: _animationController,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
