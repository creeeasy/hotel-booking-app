import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VisitorStream {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String visitorId = FirebaseAuth.instance.currentUser!.uid;

  final StreamController<List<String>> _favoritesStreamController =
      StreamController<List<String>>.broadcast();
  final StreamController<List<String>> _bookingsStreamController =
      StreamController<List<String>>.broadcast();

  VisitorStream() {
    _listenToFavorites();
    _listenToBookings();
  }

  Stream<List<String>> get favoritesStream => _favoritesStreamController.stream;
  Stream<List<String>> get bookingsStream => _bookingsStreamController.stream;

  void _listenToFavorites() {
    _firestore.collection('visitors').doc(visitorId).snapshots().listen((doc) {
      if (doc.exists) {
        final data = doc.data();
        final favorites = List<String>.from(data?['favorites'] ?? []);
        _favoritesStreamController.add(favorites);
      }
    }, onError: (e) => log('Error fetching favorites: $e'));
  }

  Future<void> addFavorite(String itemId) async {
    try {
      await _firestore.collection('visitors').doc(visitorId).update({
        'favorites': FieldValue.arrayUnion([itemId]),
      });
    } catch (e) {
      log('Error adding favorite: $e');
    }
  }

  Future<void> removeFavorite(String itemId) async {
    try {
      await _firestore.collection('visitors').doc(visitorId).update({
        'favorites': FieldValue.arrayRemove([itemId]),
      });
    } catch (e) {
      log('Error removing favorite: $e');
    }
  }

  void _listenToBookings() {
    _firestore.collection('visitors').doc(visitorId).snapshots().listen((doc) {
      if (doc.exists) {
        final data = doc.data();
        final bookings = List<String>.from(data?['bookings'] ?? []);
        _bookingsStreamController.add(bookings);
      }
    }, onError: (e) => log('Error fetching bookings: $e'));
  }

  Future<void> addBooking(String bookingId) async {
    try {
      await _firestore.collection('visitors').doc(visitorId).update({
        'bookings': FieldValue.arrayUnion([bookingId]),
      });
    } catch (e) {
      log('Error adding booking: $e');
    }
  }

  Future<void> removeBooking(String bookingId) async {
    try {
      await _firestore.collection('visitors').doc(visitorId).update({
        'bookings': FieldValue.arrayRemove([bookingId]),
      });
    } catch (e) {
      log('Error removing booking: $e');
    }
  }

  void dispose() {
    _favoritesStreamController.close();
    _bookingsStreamController.close();
  }
}
