import '../../../models/ai_plan_request_model.dart';
import '../../../models/ai_plan_response_model.dart';
import '../../../services/ai/gemini_service.dart';
import '../../../services/firebase/firestore_service.dart';
import '../../../services/storage/local_storage_service.dart';

class AiRepository {
  final GeminiService _gemini;
  final FirestoreService _firestore;
  AiRepository(this._gemini, this._firestore);

  Future<AiPlanResponseModel> generateAndSave(AiPlanRequestModel request, String userId) async {
    final result = await _gemini.generateStudyPlan(request);
    if (result.success) {
      await _firestore.savePlan(userId, result.plan);
      await LocalStorageService.cachePlan(result.plan.toMap());
      await LocalStorageService.setOnboarded(true);
    }
    return result;
  }
}
