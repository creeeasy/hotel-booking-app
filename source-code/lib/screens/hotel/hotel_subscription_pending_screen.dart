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
    extends State<HotelSubscriptionPendingScreen> {
  late Hotel hotel;

  @override
  void initState() {
    super.initState();
    hotel = context.read<AuthBloc>().state.currentUser as Hotel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Adaptive layout based on screen width
          final bool isWideScreen = constraints.maxWidth > 600;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWideScreen ? 800 : double.infinity,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Banner image if available
                        if (hotel.images.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeColors.shadow,
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                height: isWideScreen ? 260 : 200,
                                decoration: BoxDecoration(
                                  color: ThemeColors.grey200,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black45,
                                    ],
                                  ),
                                ),
                                child: Image.network(
                                  hotel.images.first,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: ThemeColors.primaryLight.withOpacity(0.15),
                                      child: const Center(
                                        child: Icon(
                                          Iconsax.building_4,
                                          size: 72,
                                          color: ThemeColors.primary,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 40),

                        // Welcome message with improved typography
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome,",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: ThemeColors.textSecondary.withOpacity(0.8),
                                letterSpacing: 0.2,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              hotel.hotelName,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: ThemeColors.primaryDark,
                                letterSpacing: 0.5,
                                fontFamily: 'Poppins',
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Subscription status message with enhanced styling
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                ThemeColors.warning.withOpacity(0.05),
                                ThemeColors.warning.withOpacity(0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: ThemeColors.warning.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeColors.warning.withOpacity(0.12),
                                blurRadius: 12,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: ThemeColors.warning.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Iconsax.warning_2,
                                      color: ThemeColors.warning,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      "Your subscription is not active",
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700,
                                        color: ThemeColors.textPrimary.withOpacity(0.9),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Please contact support to activate your hotel account.",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: ThemeColors.textSecondary.withOpacity(0.85),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Hotel information card with premium styling
                        Container(
                          decoration: BoxDecoration(
                            color: ThemeColors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeColors.primary.withOpacity(0.08),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Iconsax.info_circle,
                                      color: ThemeColors.primary,
                                      size: 24,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Account Information",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: ThemeColors.primary,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Divider(
                                  color: ThemeColors.grey300.withOpacity(0.6),
                                  height: 32,
                                  thickness: 1.5,
                                ),
                                _buildInfoRow(
                                  context,
                                  Iconsax.sms,
                                  "Email",
                                  hotel.email,
                                ),
                                const SizedBox(height: 20),
                                if (hotel.contactInfo != null) ...[
                                  _buildInfoRow(
                                    context,
                                    Iconsax.call,
                                    "Contact",
                                    hotel.contactInfo!,
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Contact support button with premium styling
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeColors.primary.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            icon: const Icon(Iconsax.support, size: 24),
                            label: const Text(
                              "Contact Support",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeColors.primary,
                              foregroundColor: ThemeColors.textOnPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: () {
                              // Add contact support logic here
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Contact support feature coming soon"),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: ThemeColors.primaryDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Sign out button with improved styling
                        TextButton.icon(
                          icon: const Icon(
                            Iconsax.logout,
                            size: 20,
                            color: ThemeColors.textSecondary,
                          ),
                          label: const Text(
                            "Sign Out",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.textSecondary,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            // Add sign out logic here
                            context.read<AuthBloc>().add(const AuthEventLogOut());
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
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ThemeColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: ThemeColors.primary,
          ),
        ),
        const SizedBox(width: 16),
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