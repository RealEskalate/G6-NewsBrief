import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/theme_storage.dart';
import 'app_theme.dart';
import 'package:flutter/material.dart';

class ThemeCubit extends Cubit<ThemeData> {
  final ThemeStorage storage;
  bool isDark = false;

  ThemeCubit(this.storage) : super(AppTheme.lightTheme) {
    loadTheme();
  }

  void loadTheme() async {
    isDark = await storage.getTheme();
    emit(isDark ? AppTheme.darkTheme : AppTheme.lightTheme);
  }

  void toggleTheme() {
    isDark = !isDark;
    emit(isDark ? AppTheme.darkTheme : AppTheme.lightTheme);
    storage.saveTheme(isDark);
  }
}
