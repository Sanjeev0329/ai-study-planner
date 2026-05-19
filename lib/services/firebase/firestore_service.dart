import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/study_plan.dart';
import '../../models/progress_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> savePlan(String uid, StudyPlanModel plan, {bool isNew = false}) async {
    final map = plan.toMap();
    map['userId'] = uid;
    map['updatedAt'] = FieldValue.serverTimestamp();
    if (isNew) map['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('users').doc(uid).collection('plans').doc(plan.id).set(map, SetOptions(merge: true));
  }

  Future<List<StudyPlanModel>> getAllPlans(String uid) async {
    final snap = await _db.collection('users').doc(uid).collection('plans').get();
    final plans = snap.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return StudyPlanModel.fromMap(data);
    }).toList();
    plans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return plans;
  }

  Future<StudyPlanModel?> getLatestPlan(String uid) async {
    final plans = await getAllPlans(uid);
    if (plans.isEmpty) return null;
    return plans.first;
  }

  Future<StudyPlanModel?> getPlanById(String uid, String planId) async {
    final doc = await _db.collection('users').doc(uid).collection('plans').doc(planId).get();
    if (!doc.exists) return null;
    final data = Map<String, dynamic>.from(doc.data()!);
    data['id'] = doc.id;
    return StudyPlanModel.fromMap(data);
  }

  Future<void> saveProgress(ProgressModel p) async {
    await _db.collection('users').doc(p.userId).collection('progress').doc('current').set(p.toMap());
  }

  Future<ProgressModel> getProgress(String uid) async {
    final snap = await _db.collection('users').doc(uid).collection('progress').doc('current').get();
    if (!snap.exists) return ProgressModel.empty(uid);
    return ProgressModel.fromMap(snap.data()!);
  }
}
