import 'package:flutter/foundation.dart';

class AlarmProvider with ChangeNotifier {
  String _alarmTone = '';
  String _alarmPath = '';
  String get alarmTone => _alarmTone;
  String get alarmPath => _alarmPath;

  void updateSelectedValue(String newValue) {
    _alarmTone = newValue;
    notifyListeners();
  }
   void updateSelectedPath(String newValue) {
    _alarmPath = newValue;
    notifyListeners();
  }
}
