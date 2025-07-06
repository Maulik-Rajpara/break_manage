import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class UserService {
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  String _generateReferralCode([int length = 10]) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<bool> userExists(String username) async {
    final query = await usersRef.where('username', isEqualTo: username).limit(1).get();
    return query.docs.isNotEmpty;
  }

  Future<String?> getUserIdByReferralCode(String referralCode) async {
    final query = await usersRef.where('referal_code', isEqualTo: referralCode).limit(1).get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.id;
  }

  Future<void> registerUser(String username, String password, {String? referral}) async {
    // Check if username already exists
    final exists = await userExists(username);
    if (exists) throw Exception('Username already exists');

    String? parentId;
    if (referral != null && referral.isNotEmpty) {
      parentId = await getUserIdByReferralCode(referral);
      if (parentId == null) {
        throw Exception('Invalid referral code');
      }
    }

    final referalCode = _generateReferralCode();
    await usersRef.add({
      'username': username,
      'password': password,
      'referal_code': referalCode,
      'parent_id': parentId,
      'onboarded': false,
    });
  }

  Future<bool> validateUser(String username, String password) async {
    final query = await usersRef.where('username', isEqualTo: username).limit(1).get();
    if (query.docs.isEmpty) return false;
    final data = query.docs.first.data() as Map<String, dynamic>?;
    return data != null && data['password'] == password;
  }

  Future<String?> getReferral(String username) async {
    final query = await usersRef.where('username', isEqualTo: username).limit(1).get();
    if (query.docs.isEmpty) return null;
    final data = query.docs.first.data() as Map<String, dynamic>?;
    return data?['referal_code'] as String?;
  }

  Future<String?> getUserIdByUsername(String username) async {
    final query = await usersRef.where('username', isEqualTo: username).limit(1).get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.id;
  }

  Future<void> setUserOnboarded(String userId, bool onboarded) async {
    await usersRef.doc(userId).update({'onboarded': onboarded});
  }

  Future<bool> isUserOnboarded(String userId) async {
    final doc = await usersRef.doc(userId).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>?;
    return data?['onboarded'] == true;
  }
} 