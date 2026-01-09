import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppThemeMode { light, dark, system }

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void updateTheme(ThemeMode mode) {
    emit(mode);
  }

  // TODO: Add Shared Preferences persistence logic here in a real implementation
  // e.g., await prefs.setInt('theme', mode.index);
}
