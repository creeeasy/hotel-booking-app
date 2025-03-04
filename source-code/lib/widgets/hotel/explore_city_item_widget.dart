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
  late final WilayaModel wilaya;

  @override
  void initState() {
    super.initState();
    wilaya = WilayaModel(
      number: widget.wilaya.ind,
      name: widget.wilaya.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;

        // Scale elements based on height (Adaptive UI)
        final titleFontSize = height * 0.16;
        final hotelCountFontSize = height * 0.12;
        final padding = height * 0.08;
        final borderRadius = height * 0.15;
        final shadowBlur = height * 0.06;
        final imageHeight = height * 0.78;
        final hotelBadgePadding = EdgeInsets.symmetric(
          vertical: height * 0.03,
          horizontal: width * 0.04,
        );

        return GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: VisitorThemeColors.whiteColor,
              borderRadius: BorderRadius.circular(borderRadius),
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
                      wilaya.getImage(),
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Gradient Overlay for better text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),

                  // City Name with shadow and enhanced readability
                  Positioned(
                    left: padding,
                    bottom: padding * 1.2,
                    child: Text(
                      wilaya.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                        color: VisitorThemeColors.whiteColor,
                        shadows: [
                          Shadow(
                            blurRadius: shadowBlur,
                            color: Colors.black54,
                            offset: const Offset(1.5, 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Hotel Count Badge (Enhanced UI)
                  Positioned(
                    top: padding,
                    right: padding,
                    child: Container(
                      padding: hotelBadgePadding,
                      decoration: BoxDecoration(
                        color:
                            VisitorThemeColors.primaryColor.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(borderRadius * 0.5),
                      ),
                      child: Text(
                        '${widget.count} Hotels',
                        style: TextStyle(
                          color: VisitorThemeColors.whiteColor,
                          fontWeight: FontWeight.w700,
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
