import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class VisitorFavoritesStream {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String _visitorId = FirebaseAuth.instance.currentUser!.uid;

  // Change the controller to emit a List<Hotel> instead of List<String>
  static final BehaviorSubject<List<String>> _favoritesController =
      BehaviorSubject<List<String>>.seeded([]);

  static StreamSubscription? _favoritesSubscription;
  static final VisitorFavoritesStream _shared =
      VisitorFavoritesStream._sharedInstance();

  factory VisitorFavoritesStream() => _shared;

  VisitorFavoritesStream._sharedInstance() {
    listenToFavorites();
  }

  // Return a stream of Hotel objects (only subscribed ones)
  static Stream<List<String>> get favoritesStream =>
      _favoritesController.stream;

  static void listenToFavorites() {
    if (_favoritesSubscription != null) return;

    _favoritesSubscription = _firestore
        .collection('visitors')
        .doc(_visitorId)
        .snapshots()
        .listen((doc) async {
      if (!doc.exists) {
        _favoritesController.add([]); // Emit empty list if no data
        return;
      }

      final List favoriteIds =
          List<String>.from(doc.data()?['favorites'] ?? []);

      if (favoriteIds.isEmpty) {
        _favoritesController.add([]);
        return;
      }

      try {
        // Fetch all hotel documents for the favorite IDs
        final List<Hotel> hotels =
            await Future.wait(favoriteIds.map((id) async {
          final hotelDoc = await _firestore.collection('hotels').doc(id).get();
          if (hotelDoc.exists) {
            return Hotel.fromFirestore(hotelDoc);
          }
          return null;
        })).then((hotels) => hotels.whereType<Hotel>().toList());

        // Filter to include only subscribed hotels
        final List<String> subscribedHotels = hotels
            .where((hotel) => hotel.isSubscribed)
            .map((e) => e.id)
            .toList();

        // Emit only the subscribed hotels
        _favoritesController.add(subscribedHotels);
      } catch (e) {
        log('Error fetching hotel data: $e');
        _favoritesController.add([]);
      }
    }, onError: (e) => log('Error fetching favorites: $e'));
  }

  static Future<bool> addFavorite(String itemId) async {
    try {
      await _firestore.collection('visitors').doc(_visitorId).update({
        'favorites': FieldValue.arrayUnion([itemId]),
      });
      return true;
    } catch (e) {
      log('Failed to add favorite $itemId: $e');
      return false;
    }
  }

  static Future<bool> removeFavorite(String itemId) async {
    try {
      await _firestore.collection('visitors').doc(_visitorId).update({
        'favorites': FieldValue.arrayRemove([itemId]),
      });
      return true;
    } catch (e) {
      log('Failed to remove favorite $itemId: $e');
      return false;
    }
  }

  static void dispose() {
    _favoritesSubscription?.cancel();
    _favoritesController.close();
  }
}
