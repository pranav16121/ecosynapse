import 'package:flutter/material.dart';

class NavigationState extends ChangeNotifier {
  int _residentIndex = 0;
  int _adminIndex = 0;

  int get residentIndex => _residentIndex;
  int get adminIndex => _adminIndex;

  void setResidentIndex(int index) {
    _residentIndex = index;
    notifyListeners();
  }

  void setAdminIndex(int index) {
    _adminIndex = index;
    notifyListeners();
  }
}
