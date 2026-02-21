import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingService extends ChangeNotifier {
  bool _isDarkMode = false;
  int _hijriAdjustment = 0;
  int _workDays = 1;
  int _restDays = 3;
  DateTime _startDate = DateTime.now();

  bool get isDarkMode => _isDarkMode;
  int get hijriAdjustment => _hijriAdjustment;
  int get workDays => _workDays;
  int get restDays => _restDays;
  DateTime get startDate => _startDate;

  SettingService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _hijriAdjustment = prefs.getInt('hijriAdjustment') ?? 0;
    _workDays = prefs.getInt('workDays') ?? 1;
    _restDays = prefs.getInt('restDays') ?? 3;
    _startDate = DateTime.parse(
        prefs.getString('startDate') ?? DateTime.now().toIso8601String());
    notifyListeners();
  }

  // فحص اليوم: هل هو دوام بناءً على تاريخ البدء؟
  bool isWorkDay(DateTime day) {
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final check = DateTime(day.year, day.month, day.day);
    final difference = check.difference(start).inDays;

    int cycleLength = _workDays + _restDays;
    if (cycleLength == 0) return false;

    int dayInCycle = difference % cycleLength;
    if (dayInCycle < 0) dayInCycle += cycleLength;

    return dayInCycle < _workDays;
  }

  // تحديث وحفظ الإعدادات وتاريخ البدء
  Future<void> updateShiftSettings(int work, int rest, DateTime start) async {
    _workDays = work;
    _restDays = rest;
    _startDate = DateTime(start.year, start.month, start.day);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workDays', work);
    await prefs.setInt('restDays', rest);
    await prefs.setString('startDate', _startDate.toIso8601String());
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void updateHijriAdjustment(int val) async {
    _hijriAdjustment = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hijriAdjustment', val);
    notifyListeners();
  }
}
