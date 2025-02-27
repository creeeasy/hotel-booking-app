// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';

class SearchHotelView extends StatefulWidget {
  const SearchHotelView({super.key});

  @override
  _SearchHotelViewState createState() => _SearchHotelViewState();
}

class _SearchHotelViewState extends State<SearchHotelView> {
  final TextEditingController searchController = TextEditingController();
  List<Hotel> searchResults = [];

  void onSearch(String query) async {
    if (query.isEmpty) {
      setState(() => searchResults = []);
      return;
    }
    final hotels = await Hotel.findHotelsByKeyword(query);
    log(hotels.length.toString());
    setState(() => searchResults = hotels);
  }

  String formatHotelText(Hotel hotel) {
    final locationText = (hotel.location != null)
        ? Wilaya.fromIndex(hotel.location!).toString()
        : "Unknown Location";
    return "${hotel.hotelName}, $locationText";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VisitorThemeColors.whiteColor,
      appBar: AppBar(
        backgroundColor: VisitorThemeColors.primaryColor,
        title: Text(
          "Search",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: VisitorThemeColors.whiteColor,
          ),
        ),
        iconTheme: IconThemeData(color: VisitorThemeColors.whiteColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: VisitorThemeColors.lightGrayColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: searchController,
                onChanged: onSearch,
                decoration: InputDecoration(
                  hintText: "Search hotels, locations...",
                  prefixIcon: Icon(Icons.search,
                      color: VisitorThemeColors.primaryColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: searchResults.isEmpty
                  ? Center(
                      child: Text(
                        "No results found",
                        style: TextStyle(
                          fontSize: 16,
                          color: VisitorThemeColors.greyColor,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(Icons.location_on,
                              color: VisitorThemeColors.primaryColor),
                          title: Text(
                            formatHotelText(searchResults[index]),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: VisitorThemeColors.blackColor,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
