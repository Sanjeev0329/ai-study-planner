import 'package:intl/intl.dart';

class DateHelper {
  static int daysUntil(DateTime target) => target.difference(DateTime.now()).inDays;
  static String formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);
  static String formatShort(DateTime date) => DateFormat('MMM d').format(date);
  static String today() => DateFormat('yyyy-MM-dd').format(DateTime.now());
}
