import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/study_plan.dart';
import '../../models/progress_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> savePlan(String uid, StudyPlanModel plan) async {
    final map = plan.toMap();
    map['createdAt'] = FieldValue.serverTimestamp();
    map['userId'] = uid;
    await _db.collection('users').doc(uid).collection('plans').doc(plan.id).set(map);
  }

  Future<StudyPlanModel?> getLatestPlan(String uid) async {
    final snap = await _db.collection('users').doc(uid).collection('plans')
        .orderBy('createdAt', descending: true).limit(1).get();
    if (snap.docs.isEmpty) return null;
    final data = snap.docs.first.data();
    data['id'] = snap.docs.first.id;
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
