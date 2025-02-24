import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class VisitorFavoritesStream {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String _visitorId = FirebaseAuth.instance.currentUser!.uid;

  static final BehaviorSubject<List<String>> _favoritesController =
      BehaviorSubject<List<String>>.seeded([]);

  static StreamSubscription<DocumentSnapshot>? _favoritesSubscription;

  static final VisitorFavoritesStream _shared =
      VisitorFavoritesStream._sharedInstance();

  factory VisitorFavoritesStream() => _shared;

  VisitorFavoritesStream._sharedInstance() {
    listenToFavorites();
  }

  static Stream<List<String>> get favoritesStream =>
      _favoritesController.stream;

  static void listenToFavorites() {
    if (_favoritesSubscription != null) return;

    _favoritesSubscription = _firestore
        .collection('visitors')
        .doc(_visitorId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) {
        _favoritesController.add([]); // Emit empty list if no data
        return;
      }

      final List<String> favorites =
          List<String>.from(doc.data()?['favorites'] ?? []);
      _favoritesController.add(favorites);
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
