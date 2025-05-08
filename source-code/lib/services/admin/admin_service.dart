import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/enum/avatar_action.dart';
import 'package:fatiel/models/admin.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  static Future<List<Admin>> getAllAdmins() async {
    try {
      final snapshot = await _admins.get();
      return snapshot.docs.map((doc) => Admin.fromFirestore(doc)).toList();
    } catch (e) {
      // Log error or handle it as needed
      throw Exception('Failed to fetch admins: $e');
    }
  }

  // Create Admin
  static Future<void> createAdmin({
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      // Create user with Firebase Authentication
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the auto-generated user ID from Firebase Auth
      final userId = userCredential.user!.uid;
      final now = DateTime.now();

      // Store only the necessary fields in Firestore
      await _admins.doc(userId).set({
        'name': name,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      // Optionally, update user profile in Firebase Auth
      await userCredential.user?.updateDisplayName(name);
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

  static Future<void> modifyAdminAvatar({
    required AvatarAction action,
    required String adminId,
    String? newAvatarUrl,
  }) async {
    final adminRef =
        FirebaseFirestore.instance.collection('admins').doc(adminId);

    switch (action) {
      case AvatarAction.update:
        if (newAvatarUrl == null) {
          throw Exception('New avatar URL is required for update action');
        }
        await adminRef.update({
          'avatarURL': newAvatarUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        break;
      case AvatarAction.remove:
        await adminRef.update({
          'avatarURL': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        break;
    }
  }
}
