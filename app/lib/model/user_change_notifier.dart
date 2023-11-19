import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserChangeNotifier extends ChangeNotifier {
  User? _user;
  late bool _isLogged;

  User? get user => _user;
  bool get isLogged => _isLogged;

  set user(User? user) {
    _user = user;
    _isLogged = user != null;
    notifyListeners();
  }
}
