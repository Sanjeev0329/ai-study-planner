import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_provider.dart';

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.authStateChanges.map((user) {
    if (user == null) return null;
    return UserModel(uid: user.uid, email: user.email ?? '', name: user.displayName ?? '', photoUrl: user.photoURL);
  });
});
