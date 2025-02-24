import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class VisitorBookingsStream {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String _visitorId = FirebaseAuth.instance.currentUser!.uid;

  static final BehaviorSubject<List<String>> _bookingsController =
      BehaviorSubject<List<String>>.seeded([]);

  static StreamSubscription<DocumentSnapshot>? _bookingSubscription;

  static final VisitorBookingsStream _shared =
      VisitorBookingsStream._sharedInstance();

  factory VisitorBookingsStream() => _shared;

  VisitorBookingsStream._sharedInstance() {
    listenToBookings(null);
  }

  static Stream<List<String>> get bookingsStream => _bookingsController.stream;

  static void listenToBookings(BookingStatus? status) {
    _bookingSubscription?.cancel();
    if (status == null) {
      return _bookingsController.add([]);
    }
    _bookingSubscription = _firestore
        .collection('visitors')
        .doc(_visitorId)
        .snapshots()
        .listen((doc) async {
      if (!doc.exists) {
        _bookingsController.add([]);
        return;
      }

      final List<String> bookingIds =
          List<String>.from(doc.data()?['bookings'] ?? []);
      final List<String> filteredBookings = [];

      for (final bookingId in bookingIds) {
        final bookingDoc =
            await _firestore.collection('bookings').doc(bookingId).get();
        final bookingData = bookingDoc.data() as Map<String, dynamic>?;

        if (bookingData?['status'].toString() == status.name) {
          filteredBookings.add(bookingId);
        }
      }

      _bookingsController.add(filteredBookings);
    }, onError: (e) => log('Error fetching bookings: $e'));
  }

  static Future<bool> addBooking(String bookingId) async {
    try {
      await _firestore.collection('visitors').doc(_visitorId).update({
        'bookings': FieldValue.arrayUnion([bookingId]),
      });
      return true;
    } catch (e) {
      log('Failed to add booking: $e');
      return false;
    }
  }

  static Future<bool> removeBooking(String bookingId) async {
    try {
      await _firestore.collection('visitors').doc(_visitorId).update({
        'bookings': FieldValue.arrayRemove([bookingId]),
      });
      return true;
    } catch (e) {
      log('Failed to remove booking: $e');
      return false;
    }
  }

  static Future<bool> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': BookingStatus.cancelled.name,
      });
      log('Booking $bookingId successfully cancelled.');
      return true;
    } catch (e) {
      log('Failed to cancel booking $bookingId: $e');
      return false;
    }
  }

  static void dispose() {
    _bookingSubscription?.cancel();
    _bookingsController.close();
  }
}
