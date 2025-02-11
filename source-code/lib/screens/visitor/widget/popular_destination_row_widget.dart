import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/hotel_entity.dart';
import 'package:flutter/material.dart';

class PopularDestinationRowWidget extends StatelessWidget {
  final VoidCallback? callback;
  final HotelEntity? popularList;
  final AnimationController? animationController;
  final Animation? animation;

  const PopularDestinationRowWidget(
      {Key? key,
      this.popularList,
      this.animationController,
      this.animation,
      this.callback})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation as Animation<double>,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation!.value), 0.0, 0.0),
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                callback!();
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, bottom: 24, top: 16, right: 8),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: VisitorThemeColors.primaryColor,
                        offset: Offset(4, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    child: Stack(
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 2,
                          child: Image.asset(
                            popularList!.imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        VisitorThemeColors.primaryColor
                                            .withOpacity(0.4),
                                        VisitorThemeColors.primaryColor
                                            .withOpacity(0.0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, bottom: 32, top: 8),
                                    child: Text(
                                      popularList!.titleTxt,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24,
                                        color:
                                            VisitorThemeColors.lightGrayColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
