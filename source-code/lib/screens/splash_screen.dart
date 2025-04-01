import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<Color?> _gradientAnimation;
  late Animation<double> _textGlowAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Animation configurations
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOutQuint),
    ));

    _scaleAnimation = Tween(begin: 0.85, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _bounceAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.fastOutSlowIn),
    ));

    _gradientAnimation = ColorTween(
      begin: ThemeColors.primary.withOpacity(0.2),
      end: ThemeColors.primary.withOpacity(0.8),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
    ));

    _textGlowAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOutBack),
    ));

    _textSlideAnimation = Tween(begin: 20.0, end: 0.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutQuad),
    ));

    _progressAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
    ));

    _controller.forward().then((_) {
      // Small delay at the end of animation before navigation
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, authFlowRoute);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Animated gradient background
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2 + (0.3 * _controller.value),
                        colors: [
                          _gradientAnimation.value ?? ThemeColors.background,
                          ThemeColors.background,
                        ],
                        stops: const [0.1, 1.0],
                      ),
                    ),
                  ),
                ),

                Center(
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Hotel logo with bounce effect
                          Transform.translate(
                            offset:
                                Offset(0, -25 * (1 - _bounceAnimation.value)),
                            child: Transform.scale(
                              scale: 1 + (0.15 * _bounceAnimation.value),
                              child: SvgPicture.asset(
                                'assets/icons/splash_screen.svg',
                                height: 180,
                                colorFilter: ColorFilter.mode(
                                  ThemeColors.primary.withOpacity(
                                    0.7 + (0.3 * _fadeAnimation.value),
                                  ),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // App name with glow effect
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glow effect
                              AnimatedBuilder(
                                animation: _textGlowAnimation,
                                builder: (context, child) {
                                  return Text(
                                    "Fatiel Hotels",
                                    style: TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins',
                                      color: Colors.transparent,
                                      shadows: [
                                        Shadow(
                                          color: ThemeColors.primary
                                              .withOpacity(0.4 *
                                                  _textGlowAnimation.value),
                                          blurRadius:
                                              15 * _textGlowAnimation.value,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              // Solid text
                              Transform.translate(
                                offset: Offset(0, _textSlideAnimation.value),
                                child: Text(
                                  "Fatiel Hotels",
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                    color: ThemeColors.primaryDark,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Tagline with fade and slide
                          Opacity(
                            opacity: _fadeAnimation.value,
                            child: Transform.translate(
                              offset:
                                  Offset(0, 15 * (1 - _fadeAnimation.value)),
                              child: const Text(
                                "Luxury redefined",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  color: ThemeColors.textSecondary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 56),

                          // Animated progress indicator
                          SizedBox(
                            width: 160,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progressAnimation.value,
                                minHeight: 3,
                                backgroundColor:
                                    ThemeColors.grey200.withOpacity(0.5),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ThemeColors.primary.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Luxury watermark
                Positioned(
                  bottom: 32,
                  right: 0,
                  left: 0,
                  child: Center(
                    child: Opacity(
                      opacity: 0.5 + (0.3 * _controller.value),
                      child: Text(
                        "EST. ${DateTime.now().year}",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                          color: ThemeColors.textSecondary,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
