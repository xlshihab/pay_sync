import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';

// States
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

class ThemeLight extends ThemeState {}
class ThemeDark extends ThemeState {}

// Cubit
class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeCubit() : super(ThemeLight()) {
    _loadTheme();
  }

  void toggleTheme() {
    if (state is ThemeLight) {
      emit(ThemeDark());
      _saveTheme(false);
    } else {
      emit(ThemeLight());
      _saveTheme(true);
    }
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isLight = prefs.getBool(_themeKey) ?? true;
    emit(isLight ? ThemeLight() : ThemeDark());
  }

  void _saveTheme(bool isLight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isLight);
  }
}
