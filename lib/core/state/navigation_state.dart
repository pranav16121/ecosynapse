import 'package:flutter/material.dart';

class NavigationState extends ChangeNotifier {
  int _residentIndex = 0;
  int _adminIndex = 0;
  int _collectorIndex = 0;
  int _recyclerIndex = 0;

  int get residentIndex => _residentIndex;
  int get adminIndex => _adminIndex;
  int get collectorIndex => _collectorIndex;
  int get recyclerIndex => _recyclerIndex;

  void setResidentIndex(int index) {
    _residentIndex = index;
    notifyListeners();
  }

  void setAdminIndex(int index) {
    _adminIndex = index;
    notifyListeners();
  }

  void setCollectorIndex(int index) {
    _collectorIndex = index;
    notifyListeners();
  }

  void setRecyclerIndex(int index) {
    _recyclerIndex = index;
    notifyListeners();
  }
}
