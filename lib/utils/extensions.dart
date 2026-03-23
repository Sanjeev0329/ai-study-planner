import 'package:flutter/material.dart';

extension StringExt on String {
  String get capitalize => isEmpty ? this : '\${this[0].toUpperCase()}\${substring(1)}';
}

extension ContextExt on BuildContext {
  void showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }
  void push(String route, {Object? args}) => Navigator.pushNamed(this, route, arguments: args);
  void pushReplace(String route) => Navigator.pushReplacementNamed(this, route);
  void pop() => Navigator.pop(this);
}
