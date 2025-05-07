import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/models/admin.dart';

class AdminService {
  static final _admins = FirebaseFirestore.instance.collection('admins');

  // Get admin by ID
  static Future<Admin?> getAdminById(String adminId) async {
    try {
      final doc = await _admins.doc(adminId).get();
      if (doc.exists && doc.data() != null) {
        return Admin.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting admin: $e');
      return null;
    }
  }

  // Get all admins
  static Stream<List<Admin>> getAllAdmins() {
    return _admins.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Admin.fromFirestore(doc)).toList();
    });
  }

  // Create Admin
  static Future<void> createAdmin({
    required String userId,
    required String email,
    required String name,
  }) async {
    try {
      final now = DateTime.now();
      final admin = Admin(
        id: userId,
        email: email,
        name: name,
        createdAt: now,
        updatedAt: now,
      );

      await _admins.doc(userId).set(admin.toFirestore());
    } catch (e) {
      print('Error creating admin: $e');
      rethrow;
    }
  }

  // Update Admin Name
  static Future<void> updateAdminName({
    required String adminId,
    required String newName,
  }) async {
    try {
      await _admins.doc(adminId).update({
        'name': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating admin name: $e');
      rethrow;
    }
  }

  // Delete Admin
  static Future<void> deleteAdmin(String adminId) async {
    try {
      await _admins.doc(adminId).delete();
    } catch (e) {
      print('Error deleting admin: $e');
      rethrow;
    }
  }

  // Toggle hotel subscription status
  static Future<void> toggleHotelSubscription({
    required String hotelId,
    required bool isSubscribed,
  }) async {
    try {
      final hotels = FirebaseFirestore.instance.collection('hotels');

      await hotels.doc(hotelId).update({
        'isSubscribed': isSubscribed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error toggling hotel subscription: $e');
      rethrow;
    }
  }

  // Promote user to admin
  static Future<void> promoteToAdmin({
    required String userId,
    required String email,
    required String name,
  }) async {
    try {
      final now = DateTime.now();
      final admin = Admin(
        id: userId,
        email: email,
        name: name,
        createdAt: now,
        updatedAt: now,
      );

      await _admins.doc(userId).set(admin.toFirestore());
    } catch (e) {
      print('Error promoting user to admin: $e');
      rethrow;
    }
  }
}
