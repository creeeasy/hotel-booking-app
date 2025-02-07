import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
// import 'package:fatiel/screens/location_selection_screen.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HotelRegistrationView extends StatefulWidget {
  const HotelRegistrationView({super.key});

  @override
  State<StatefulWidget> createState() => _HotelRegistrationViewState();
}

class _HotelRegistrationViewState extends State<HotelRegistrationView> {
  var hotelName = TextEditingController();
  var id = TextEditingController();
  var password = TextEditingController();

  bool notVisiblePassword = true;

  void passwordVisibility() {
    setState(() {
      notVisiblePassword = !notVisiblePassword;
    });
  }

  void createHotelAccount() {
    // Navigate to the next page to select hotel location
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSelectionPage(
            hotelName: hotelName.text, id: id.text, password: password.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.lightGrayColor,
      appBar: AppBar(
        leading: IconButton(
          color: ThemeColors.blackColor,
          icon: const Icon(
            Icons.chevron_left,
            size: 32, // Matching Visitor screen
          ),
          onPressed: () {
            context.read<AuthBloc>().add(const AuthEventShouldRegister());
          },
        ),
        backgroundColor: ThemeColors.lightGrayColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Hotel Registration',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: ThemeColors.blackColor,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 24.0), // Consistent padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Register your hotel",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: ThemeColors.blackColor,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12), // Consistent spacing
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Hotel Name',
                icon: Icon(Icons.business, color: ThemeColors.blackColor),
                labelStyle: TextStyle(
                  color: ThemeColors.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeColors.primaryColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeColors.primaryColor),
                ),
              ),
              controller: hotelName,
              cursorColor: ThemeColors.primaryColor,
            ),
            const SizedBox(height: 15),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email ID',
                icon: Icon(Icons.alternate_email_outlined,
                    color: ThemeColors.blackColor),
                labelStyle: TextStyle(
                  color: ThemeColors.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeColors.primaryColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeColors.primaryColor),
                ),
              ),
              controller: id,
              cursorColor: ThemeColors.primaryColor,
            ),
            const SizedBox(height: 15),
            TextFormField(
              obscureText: notVisiblePassword,
              decoration: InputDecoration(
                icon: const Icon(Icons.lock_outline_rounded,
                    color: ThemeColors.blackColor),
                labelText: 'Password',
                labelStyle: const TextStyle(
                  color: ThemeColors.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeColors.primaryColor),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeColors.primaryColor),
                ),
                suffixIcon: IconButton(
                  onPressed: passwordVisibility,
                  icon: Icon(
                    notVisiblePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: ThemeColors.blackColor,
                  ),
                ),
              ),
              controller: password,
              cursorColor: ThemeColors.primaryColor,
            ),
            const SizedBox(height: 40), // Matched spacing
            ElevatedButton(
              onPressed: createHotelAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primaryColor,
                minimumSize: const Size.fromHeight(50), // Matched button size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Next Step",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: ThemeColors.whiteColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationSelectionPage extends StatelessWidget {
  final String hotelName;
  final String id;
  final String password;

  LocationSelectionPage({
    required this.hotelName,
    required this.id,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.lightGrayColor,
      appBar: AppBar(
        leading: IconButton(
          color: ThemeColors.blackColor,
          icon: const Icon(
            Icons.chevron_left,
            size: 32, // Matching other screens
          ),
          onPressed: () {
            context.read<AuthBloc>().add(const AuthEventShouldRegister());
          },
        ),
        backgroundColor: ThemeColors.lightGrayColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pick Hotel Location',
          style: TextStyle(
            color: ThemeColors.blackColor,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 24.0), // Consistent padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Please select the hotel location",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: ThemeColors.blackColor,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12), // Consistent spacing
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Location',
                icon: Icon(Icons.location_on, color: ThemeColors.blackColor),
                labelStyle: TextStyle(
                  color: ThemeColors.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeColors.primaryColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeColors.primaryColor),
                ),
              ),
              onChanged: (String? value) {
                // Handle location selection logic
              },
              items: <String>['Location 1', 'Location 2', 'Location 3']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.06),
            ElevatedButton(
              onPressed: () {
                // Handle form submission or navigate to next step
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primaryColor,
                minimumSize: const Size.fromHeight(50), // Matched button size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Submit Registration",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: ThemeColors.whiteColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
