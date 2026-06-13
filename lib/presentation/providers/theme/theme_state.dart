import 'package:flutter/material.dart';

class ThemeState {
  final ThemeData themeData;

  const ThemeState({required this.themeData});

  ThemeState copyWith({ThemeData? themeData}) {
    return ThemeState(themeData: themeData ?? this.themeData);
  }
}
