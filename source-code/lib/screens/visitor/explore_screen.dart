import 'dart:developer';

import 'package:fatiel/models/Visitor.dart';
import 'package:fatiel/services/auth/auth_provider.dart';
import 'package:fatiel/services/auth/auth_service.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExploreView extends StatelessWidget {
  final wilayasList = Wilaya.wilayasList;
  final List<Map<String, String>> hotels = [
    {'name': 'Hotel A', 'image': 'assets/hotel1.jpg'},
    {'name': 'Hotel B', 'image': 'assets/hotel2.jpg'},
    {'name': 'Hotel C', 'image': 'assets/hotel3.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final visitorInformations = state.currentUser as Visitor;
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(title: Text('Explore'), centerTitle: true),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserProfile(
                        "${visitorInformations.firstName} ${visitorInformations.lastName}"),
                    SizedBox(height: 20),
                    _buildSearchBar(),
                    SizedBox(height: 20),
                    _buildSectionTitle('Popular Hotels'),
                    SizedBox(height: 10),
                    _buildHotelSlider(),
                    SizedBox(height: 20),
                    _buildSectionTitle('Explore Cities'),
                    SizedBox(height: 10),
                    _buildCityCarousel(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserProfile(String visitorName) {
    return Row(
      children: [
        CircleAvatar(
            radius: 30, backgroundImage: AssetImage('assets/user.jpg')),
        SizedBox(width: 10),
        Text(visitorName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for hotels...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildHotelSlider() {
    return CarouselSlider(
      options:
          CarouselOptions(autoPlay: true, height: 180, enlargeCenterPage: true),
      items: hotels
          .map((hotel) => _buildHotelCard(hotel['name']!, hotel['image']!))
          .toList(),
    );
  }

  Widget _buildHotelCard(String name, String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity),
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.black54,
            child: Text(name,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCityCarousel() {
    return CarouselSlider(
      options:
          CarouselOptions(autoPlay: true, height: 150, enlargeCenterPage: true),
      items: wilayasList.map((wilaya) => _buildCityCard(wilaya)).toList(),
    );
  }

  Widget _buildCityCard(Wilaya wilaya) {
    final instance = WilayaModel(number: wilaya.ind, name: wilaya.name);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(instance.getImage(),
                width: double.infinity, height: 150, fit: BoxFit.cover),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            color: Colors.black54,
            child: Text(instance.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
