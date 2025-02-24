// import 'dart:async';
// import 'dart:developer';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fatiel/enum/booking_status.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class VisitorStream {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final String visitorId = FirebaseAuth.instance.currentUser!.uid;
//   final StreamController<List<String>> _favoritesStreamController =
//       StreamController<List<String>>.broadcast();
//   final StreamController<List<String>> _bookingsStreamController =
//       StreamController<List<String>>.broadcast();
//   final StreamController<BookingStatus> _bookingStatusController =
//       StreamController<BookingStatus>.broadcast();
//   StreamSubscription? _bookingSubscription;
//   VisitorStream(BookingStatus initialStatus) {
//     _listenToFavorites();
//     _bookingStatusController.add(initialStatus);
//     _bookingStatusController.stream.listen((status) {
//       _listenToBookings(status);
//     });
//   }

//   Stream<List<String>> get favoritesStream => _favoritesStreamController.stream;
//   Stream<List<String>> get bookingsStream => _bookingsStreamController.stream;

//   void _listenToFavorites() {
//     _firestore.collection('visitors').doc(visitorId).snapshots().listen((doc) {
//       if (doc.exists) {
//         final data = doc.data();
//         final favorites = List<String>.from(data?['favorites'] ?? []);
//         _favoritesStreamController.add(favorites);
//       }
//     }, onError: (e) => log('Error fetching favorites: $e'));
//   }

//   Future<void> addFavorite(String itemId) async {
//     try {
//       await _firestore.collection('visitors').doc(visitorId).update({
//         'favorites': FieldValue.arrayUnion([itemId]),
//       });
//     } catch (e) {
//       log('Error adding favorite: $e');
//     }
//   }

//   Future<void> removeFavorite(String itemId) async {
//     try {
//       await _firestore.collection('visitors').doc(visitorId).update({
//         'favorites': FieldValue.arrayRemove([itemId]),
//       });
//     } catch (e) {
//       log('Error removing favorite: $e');
//     }
//   }

//   void _listenToBookings(BookingStatus status) {
//     _bookingSubscription?.cancel();
//     _firestore.collection('visitors').doc(visitorId).snapshots().listen(
//       (doc) async {
//         if (!doc.exists) {
//           _bookingsStreamController.add([]); // Emit empty list if no data
//           return;
//         }

//         final data = doc.data();
//         final List<String> bookingIds =
//             List<String>.from(data?['bookings'] ?? []);

//         List<String> filteredBookings = [];

//         for (String bookingId in bookingIds) {
//           DocumentSnapshot bookingDoc =
//               await _firestore.collection('bookings').doc(bookingId).get();

//           if (bookingDoc.exists) {
//             if (bookingDoc.exists) {
//               final bookingData = bookingDoc.data() as Map<String, dynamic>?;
//               if (bookingData != null &&
//                   bookingData['status'].toString() == status.name) {
//                 filteredBookings.add(bookingId);
//               }
//             }
//           }
//         }

//         _bookingsStreamController.add(filteredBookings);
//       },
//       onError: (e) => log('Error fetching bookings: $e'),
//     );
//   }

//   Future<void> addBooking(String bookingId) async {
//     try {
//       await _firestore.collection('visitors').doc(visitorId).update({
//         'bookings': FieldValue.arrayUnion([bookingId]),
//       });
//     } catch (e) {
//       log('Error adding booking: $e');
//     }
//   }

//   Future<void> removeBooking(String bookingId) async {
//     try {
//       await _firestore.collection('visitors').doc(visitorId).update({
//         'bookings': FieldValue.arrayRemove([bookingId]),
//       });
//     } catch (e) {
//       log('Error removing booking: $e');
//     }
//   }

//   void dispose() {
//     _favoritesStreamController.close();
//     _bookingsStreamController.close();
//     _bookingStatusController.close();
//     _bookingSubscription?.cancel();
//   }
// }
