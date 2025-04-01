import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/helper/auth_helper.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/services/hotel/hotel_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:iconsax/iconsax.dart';

bool isValidUrl(String url) {
  try {
    Uri.parse(url);
    return Uri.parse(url).isAbsolute;
  } catch (e) {
    return false;
  }
}

class HotelDetailsCompletion extends StatefulWidget {
  const HotelDetailsCompletion({super.key});

  @override
  State<HotelDetailsCompletion> createState() => _HotelDetailsCompletionState();
}

class _HotelDetailsCompletionState extends State<HotelDetailsCompletion> {
  int currentIndex = 0;
  final PageController _pageController = PageController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _mapLinkController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  bool isLoading = false;

  void updateHotelDetails(BuildContext context, Hotel hotel) async {
    final controller = getStepData()['controller'] as TextEditingController;
    final input = controller.text.trim();
    if (currentIndex == 2 && !isValidUrl(input)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Type a valid url!")),
      );
      return;
    } else if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Input can't be empty!")),
      );
      return;
    }

    setState(() => isLoading = true);
    await HotelService.updateHotelDetails(
        hotelId: hotel.id, step: currentIndex, newValue: input);
    setState(() => isLoading = false);

    if (currentIndex < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => currentIndex++);
    } else {
      context.read<AuthBloc>().add(const AuthEventHotelLogIn());
    }
  }

  Map<String, dynamic> getStepData() {
    switch (currentIndex) {
      case 0:
        return {'title': "Update Location", 'controller': _locationController};
      case 1:
        return {
          'title': "Update Description",
          'controller': _descriptionController
        };
      case 2:
        return {'title': "Update Map Link", 'controller': _mapLinkController};
      case 3:
        return {
          'title': "Update Contact Information",
          'controller': _contactInfoController
        };
      default:
        return {};
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthStateHotelDetailsCompletion) {
        final hotel = authState.hotel;
        if (hotel != null) {
          _locationController.text = hotel.location?.toString() ?? "";
          _descriptionController.text = hotel.description ?? '';
          _mapLinkController.text = hotel.mapLink ?? '';
          _contactInfoController.text = hotel.contactInfo ?? '';
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthStateHotelDetailsCompletion) {
            final stepData = getStepData();
            final value = _locationController.text;
            return Scaffold(
              backgroundColor: ThemeColors.background,
              appBar: CustomBackAppBar(
                title: "Complete Your Hotel Profile",
                titleSize: 19,
                icon: Iconsax.logout,
                onBack: () => handleLogout(context),
              ),
              body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stepData['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        itemBuilder: (_, index) => index == 0
                            ? DropdownButton<int>(
                                key: ValueKey<String>(value),
                                elevation: 0,
                                value: _locationController.text.isNotEmpty
                                    ? int.tryParse(_locationController.text)
                                    : null,
                                hint: const Text("Select a Wilaya"),
                                isExpanded: true,
                                onChanged: (int? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _locationController.text =
                                          newValue.toString();
                                    });
                                  }
                                },
                                items: Wilaya.wilayasList.map((Wilaya wilaya) {
                                  final title = "${wilaya.name} ${wilaya.ind}";
                                  return DropdownMenuItem<int>(
                                    value: wilaya.ind,
                                    child: Text(title),
                                  );
                                }).toList(),
                              )
                            : TextField(
                                controller: stepData['controller'],
                                decoration: InputDecoration(
                                  hintText:
                                      "Enter ${stepData['title']?.toLowerCase()}...",
                                  hintStyle: TextStyle(
                                      color: Colors.grey[600], fontSize: 16),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: ThemeColors.primary, width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: ThemeColors.accentPink,
                                        width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: ThemeColors.primary.withOpacity(
                                          0.77), // Replace HotelThemeColors.primaryColor
                                      width: 2,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                    color: ThemeColors.textPrimary,
                                    fontSize: 18),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        currentIndex > 0
                            ? ElevatedButton(
                                onPressed: isLoading || currentIndex == 0
                                    ? null
                                    : () {
                                        _pageController.previousPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                        setState(() => currentIndex--);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ThemeColors.grey400,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                                child: const Text(
                                  "Back",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            : const SizedBox.shrink(),
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => updateHotelDetails(context, state.hotel!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: ThemeColors.white, strokeWidth: 2),
                                )
                              : Text(
                                  currentIndex == 3 ? "Finish" : "Next",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }
}
