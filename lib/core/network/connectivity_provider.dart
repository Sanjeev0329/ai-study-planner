import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool _isOnline(List<ConnectivityResult> results) {
  if (results.isEmpty) return false;
  return !results.every((e) => e == ConnectivityResult.none);
}

/// Emits true when device has a network interface (Wi‑Fi / mobile / ethernet).
/// Note: interface up does not guarantee internet reachability.
final connectivityOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield _isOnline(await connectivity.checkConnectivity());
  await for (final results in connectivity.onConnectivityChanged) {
    yield _isOnline(results);
  }
});
