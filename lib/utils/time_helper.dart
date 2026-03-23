class TimeHelper {
  static String minutesToReadable(int minutes) {
    if (minutes < 60) return '\${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '\${h}h' : '\${h}h \${m}m';
  }

  static String formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '\$m:\$s';
  }
}
