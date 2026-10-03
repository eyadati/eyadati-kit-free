import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 100.0;

  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius dialogRadius = BorderRadius.all(Radius.circular(xl));
}