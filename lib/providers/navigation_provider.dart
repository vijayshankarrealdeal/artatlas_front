import 'package:flutter/foundation.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void onItemTapped(int index) {
    if (_selectedIndex == index) return; // Avoid unnecessary notifications
    _selectedIndex = index;
    notifyListeners();
  }
}