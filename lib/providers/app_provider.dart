import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase/auth_service.dart';
import '../services/firebase/firestore_service.dart';
import '../services/ai/gemini_service.dart';

final authServiceProvider      = Provider((_) => AuthService());
final firestoreServiceProvider = Provider((_) => FirestoreService());
final geminiServiceProvider    = Provider((_) => GeminiService());
