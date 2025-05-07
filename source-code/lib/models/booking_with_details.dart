import 'package:fatiel/models/booking.dart';

class BookingWithDetails {
  final Booking booking;
  final String visitorName;
  final String hotelName;
  final String roomName;
  final double commission;

  BookingWithDetails({
    required this.booking,
    required this.visitorName,
    required this.hotelName,
    required this.roomName,
    required this.commission,
  });
}
