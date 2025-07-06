import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingService {
  final CollectionReference onboardingRef = FirebaseFirestore.instance.collection('user_onboardings');

  Future<void> saveOnboardingData({
    required String userId,
    required List<String> tasks,
    required bool hasSmartphone,
    bool? canGetPhone,
    required bool usedGoogleMap,
    required String birthDate, // dd-mm-yyyy
  }) async {
    await onboardingRef.add({
      'user_id': userId,
      'tasks': tasks,
      'hasSmartphone': hasSmartphone,
      'canGetPhone': canGetPhone,
      'usedGoogleMap': usedGoogleMap,
      'birth_date': birthDate,
    });
  }

  Future<Map<String, dynamic>?> getOnboardingData(String userId) async {
    final query = await onboardingRef.where('user_id', isEqualTo: userId).limit(1).get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.data() as Map<String, dynamic>?;
  }
} 