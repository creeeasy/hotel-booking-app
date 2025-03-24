import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';

class UpdateUserInformation extends StatefulWidget {
  const UpdateUserInformation({super.key});

  @override
  State<UpdateUserInformation> createState() => _UpdateUserInformationState();
}

class _UpdateUserInformationState extends State<UpdateUserInformation> {
  int currentIndex = 0;
  final PageController _pageController = PageController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool isLoading = false;

  void updateUserDetails(BuildContext context) async {
    final controller = getStepData()['controller'] as TextEditingController;
    final input = controller.text.trim();

    if (input.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Input can't be empty!")),
        );
      }
      return;
    }

    if (!context.mounted) return; // Prevent unnecessary processing

    setState(() => isLoading = true);

    try {
      final visitorId =
          (context.read<AuthBloc>().state.currentUser as Visitor).id;
      await Visitor.updateUserProfile(
        visitorId: visitorId,
        step: currentIndex,
        newValue: input,
      );

      if (!context.mounted) return;

      setState(() => isLoading = false);

      if (currentIndex < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => currentIndex++);
      } else {
        await showGenericDialog<void>(
          context: context,
          title: "Success",
          content: "Your profile data has been updated successfully.",
          optionBuilder: () => {'OK': true},
        );
        if (context.mounted) {
          Navigator.of(context).pop();
          context.read<AuthBloc>().add(const AuthEventInitialize());
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: ${e.toString()}")),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Map<String, dynamic> getStepData() {
    switch (currentIndex) {
      case 0:
        return {
          'title': "Update first name",
          'controller': _firstNameController
        };
      case 1:
        return {'title': "Update last name", 'controller': _lastNameController};
      case 2:
        return {'title': "Select location", 'controller': _locationController};
      default:
        return {};
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final visitorState =
          context.read<AuthBloc>().state.currentUser as Visitor;
      _firstNameController.text = visitorState.firstName;
      _lastNameController.text = visitorState.lastName;
      _locationController.text = visitorState.location?.toString() ?? "";
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomBackAppBar(
          title: "Update Your Information",
          titleColor: VisitorThemeColors.lavenderPurple,
          iconColor: VisitorThemeColors.lavenderPurple,
          onBack: () => Navigator.of(context).pop(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getStepData()['title'] ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: VisitorThemeColors.lavenderPurple,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (_, index) => index == 2
                      ? DropdownButton<int>(
                          value: _locationController.text.isNotEmpty
                              ? int.tryParse(_locationController.text)
                              : null,
                          hint: const Text("Select a Wilaya"),
                          isExpanded: true,
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _locationController.text = newValue.toString();
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
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: getStepData()['controller'],
                              decoration: InputDecoration(
                                labelText: getStepData()['title'],
                                labelStyle: TextStyle(
                                  color: VisitorThemeColors.blackColor
                                      .withOpacity(0.23),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: VisitorThemeColors.blackColor
                                        .withOpacity(0.06),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: VisitorThemeColors.blackColor
                                        .withOpacity(0.16),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: VisitorThemeColors.cancelBorderColor,
                                    width: 1.5,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: VisitorThemeColors.cancelBorderColor,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: VisitorThemeColors.whiteColor,
                                hintText:
                                    "Enter ${getStepData()['title']?.toLowerCase()}...",
                                hintStyle: TextStyle(
                                  color: VisitorThemeColors.blackColor
                                      .withOpacity(0.3),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              cursorColor: VisitorThemeColors.lavenderPurple,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: VisitorThemeColors.blackColor,
                              ),
                            ),
                          ],
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
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                  setState(() => currentIndex--);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VisitorThemeColors.greyColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text(
                            "Back",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        )
                      : const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed:
                        isLoading ? null : () => updateUserDetails(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VisitorThemeColors.lavenderPurple,
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
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            currentIndex == 2 ? "Finish" : "Next",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
