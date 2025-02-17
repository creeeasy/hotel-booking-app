import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:flutter/material.dart';

class ExploreCityWidget extends StatefulWidget {
  final Wilaya wilaya;
  final VoidCallback? onTap;
  final int count;

  const ExploreCityWidget({
    Key? key,
    required this.wilaya,
    required this.count,
    this.onTap,
  }) : super(key: key);

  @override
  State<ExploreCityWidget> createState() => _ExploreCityWidgetState();
}

class _ExploreCityWidgetState extends State<ExploreCityWidget> {
  late final WilayaModel hotel;

  @override
  void initState() {
    super.initState();
    hotel = WilayaModel(
      number: widget.wilaya.ind,
      name: widget.wilaya.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        // Scale dimensions based on maxHeight = 130
        final titleFontSize = height * 0.15;
        final hotelCountFontSize = height * 0.10;
        final padding = height * 0.08;
        final borderRadius = height * 0.12;
        final shadowBlur = height * 0.05;
        final imageHeight = height * 0.75;

        return GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: VisitorThemeColors.whiteColor,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: VisitorThemeColors.greyColor.withOpacity(0.3),
                  blurRadius: shadowBlur,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            margin:
                EdgeInsets.symmetric(vertical: padding, horizontal: padding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Stack(
                children: <Widget>[
                  // Background Image with adjusted height
                  SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: Image.asset(
                      hotel.getImage(),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Gradient Overlay for text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          VisitorThemeColors.blackColor.withOpacity(0.6),
                          VisitorThemeColors.blackColor.withOpacity(0.0),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  // City Name with adjusted font size
                  Positioned(
                    left: padding,
                    bottom: padding,
                    child: Text(
                      hotel.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                        color: VisitorThemeColors.whiteColor,
                        shadows: [
                          Shadow(
                            blurRadius: shadowBlur,
                            color: Colors.black38,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Hotel Count with smaller dimensions
                  Positioned(
                    top: padding,
                    right: padding,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: padding * 0.4,
                        horizontal: padding,
                      ),
                      decoration: BoxDecoration(
                        color: VisitorThemeColors.primaryColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(borderRadius * 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: shadowBlur,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        '${widget.count} Hotels',
                        style: TextStyle(
                          color: VisitorThemeColors.whiteColor,
                          fontWeight: FontWeight.w600,
                          fontSize: hotelCountFontSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
