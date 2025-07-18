import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/visitor/visitor_service.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:iconsax/iconsax.dart';

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
          SnackBar(
            content: Text(
              L10n.of(context).inputCantBeEmpty,
              style: const TextStyle(color: ThemeColors.textOnDark),
            ),
            backgroundColor: ThemeColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;

    setState(() => isLoading = true);

    try {
      final visitorId =
          (context.read<AuthBloc>().state.currentUser as Visitor).id;
      await VisitorService.updateUserProfile(
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
          title: L10n.of(context).success,
          content: L10n.of(context).profileUpdatedSuccessfully,
          optionBuilder: () => {'OK': true},
        );
        if (context.mounted) {
          context.read<AuthBloc>().add(const AuthEventInitialize());
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${L10n.of(context).anErrorOccurred}: ${e.toString()}",
              style: const TextStyle(color: ThemeColors.textOnDark),
            ),
            backgroundColor: ThemeColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
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
          'title': L10n.of(context).updateFirstName,
          'controller': _firstNameController
        };
      case 1:
        return {
          'title': L10n.of(context).updateLastName,
          'controller': _lastNameController
        };
      case 2:
        return {
          'title': L10n.of(context).selectLocation,
          'controller': _locationController
        };
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
        backgroundColor: ThemeColors.background,
        appBar: CustomBackAppBar(
          title: L10n.of(context).updateYourInformation,
          titleColor: ThemeColors.primary,
          iconColor: ThemeColors.primary,
          backgroundColor: ThemeColors.background,
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
                  color: ThemeColors.primary,
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
                          hint: Text(
                            L10n.of(context).selectAWilaya,
                            style: const TextStyle(
                                color: ThemeColors.textSecondary),
                          ),
                          isExpanded: true,
                          dropdownColor: ThemeColors.surface,
                          style: const TextStyle(
                            color: ThemeColors.textPrimary,
                            fontSize: 16,
                          ),
                          icon: const Icon(
                            Iconsax.arrow_down_1,
                            color: ThemeColors.primary,
                          ),
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
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: ThemeColors.textPrimary,
                                ),
                              ),
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
                                labelStyle: const TextStyle(
                                  color: ThemeColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: ThemeColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: ThemeColors.primary,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: ThemeColors.error,
                                    width: 1.5,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: ThemeColors.error,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: ThemeColors.white,
                                hintText:
                                    "${L10n.of(context).enter} ${getStepData()['title']?.toLowerCase()}...",
                                hintStyle: const TextStyle(
                                  color: ThemeColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              cursorColor: ThemeColors.primary,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: ThemeColors.textPrimary,
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
                            backgroundColor: ThemeColors.grey300,
                            disabledBackgroundColor: ThemeColors.grey200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            L10n.of(context).back,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.textPrimary,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed:
                        isLoading ? null : () => updateUserDetails(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.primary,
                      disabledBackgroundColor: ThemeColors.grey300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      elevation: 2,
                      shadowColor: ThemeColors.shadow,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: ThemeColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            currentIndex == 2
                                ? L10n.of(context).finish
                                : L10n.of(context).next,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
