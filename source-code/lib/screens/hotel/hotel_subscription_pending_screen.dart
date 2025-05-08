import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class HotelSubscriptionPendingScreen extends StatefulWidget {
  const HotelSubscriptionPendingScreen({Key? key}) : super(key: key);

  @override
  State<HotelSubscriptionPendingScreen> createState() =>
      _HotelSubscriptionPendingScreenState();
}

class _HotelSubscriptionPendingScreenState
    extends State<HotelSubscriptionPendingScreen>
    with SingleTickerProviderStateMixin {
  late Hotel hotel;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    hotel = context.read<AuthBloc>().state.currentUser as Hotel;

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
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
    return Scaffold(
      backgroundColor: ThemeColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWideScreen = constraints.maxWidth > 600;

            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWideScreen ? 600 : double.infinity,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Hotel banner image if available
                          if (hotel.images.isNotEmpty) ...[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: ThemeColors.shadowDark
                                        .withOpacity(0.25),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  height: isWideScreen ? 260 : 200,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black54,
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        hotel.images.first,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: ThemeColors.primaryLight
                                                .withOpacity(0.15),
                                            child: const Center(
                                              child: Icon(
                                                Iconsax.building_4,
                                                size: 80,
                                                color: ThemeColors.primary,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      // Gradient overlay
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                ThemeColors.primaryDark
                                                    .withOpacity(0.7),
                                              ],
                                              stops: const [0.6, 1.0],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),
                          ],

                          // Lock icon in elegant circle
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  ThemeColors.primaryLight.withOpacity(0.3),
                                  ThemeColors.primary.withOpacity(0.15),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeColors.primary.withOpacity(0.15),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color:
                                    ThemeColors.primaryLight.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Iconsax.lock,
                              size: 52,
                              color: ThemeColors.primary,
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Welcome message with enhanced typography
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: "Hello, ",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w500,
                                    color: ThemeColors.textPrimary,
                                    fontFamily: 'Poppins',
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${hotel.hotelName} 👋",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.primary,
                              fontFamily: 'Poppins',
                              letterSpacing: 0.3,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Subscription pending message card with enhanced styling
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: ThemeColors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeColors.shadow.withOpacity(0.12),
                                  blurRadius: 24,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              border: Border.all(
                                color: ThemeColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: ThemeColors.warning
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Iconsax.timer_1,
                                        color: ThemeColors.warning,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Text(
                                        "Your subscription is still pending",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: ThemeColors.textPrimary,
                                          letterSpacing: 0.3,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "You can't use the app until your account is activated by the admin. Please check back later.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: ThemeColors.textSecondary,
                                    letterSpacing: 0.2,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Account information card with premium styling
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: ThemeColors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeColors.shadow.withOpacity(0.08),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              border: Border.all(
                                color: ThemeColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: ThemeColors.primary
                                            .withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Iconsax.info_circle,
                                        color: ThemeColors.primary,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Text(
                                      "Account Information",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: ThemeColors.primary,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: ThemeColors.grey300.withOpacity(0.6),
                                  height: 40,
                                  thickness: 1.5,
                                ),
                                _buildInfoRow(
                                  context,
                                  Iconsax.sms,
                                  "Email",
                                  hotel.email,
                                ),
                                if (hotel.contactInfo != null) ...[
                                  const SizedBox(height: 20),
                                  _buildInfoRow(
                                    context,
                                    Iconsax.call,
                                    "Contact",
                                    hotel.contactInfo!,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Additional subtle note at the bottom
                          Text(
                            "Our team will review your application shortly",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ThemeColors.textSecondary.withOpacity(0.7),
                              letterSpacing: 0.2,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Sign out button with improved styling
                          TextButton.icon(
                            icon: const Icon(
                              Iconsax.logout,
                              size: 20,
                              color: Colors.red,
                            ),
                            label: const Text(
                              "Sign Out",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(
                                    color: Colors.red, width: 1.5),
                              ),
                              foregroundColor: Colors.red,

                              backgroundColor: ThemeColors.background,
                            ),
                            onPressed: () {
                              context
                                  .read<AuthBloc>()
                                  .add(const AuthEventLogOut());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ThemeColors.primaryLight.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            size: 20,
            color: ThemeColors.primary,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textSecondary.withOpacity(0.75),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textPrimary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
