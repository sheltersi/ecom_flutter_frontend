import 'package:flutter/material.dart';
import 'package:flutter_learn2/models/user.dart';
import 'package:flutter_learn2/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => ApiService.isLoggedIn;

  Future<void> init() async {
    await ApiService.init();
    if (ApiService.isLoggedIn) {
      await _fetchUser();
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.login(email: email, password: password);
      _user = switch (data['user']) {
        Map<String, dynamic> u => User.fromJson(u),
        _ => null,
      };
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.register(
        name: name,
        email: email,
        password: password,
      );
      _user = switch (data['user']) {
        Map<String, dynamic> u => User.fromJson(u),
        _ => null,
      };
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.logout();
    } catch (_) {}
    _user = null;
    notifyListeners();
  }

  Future<void> _fetchUser() async {
    try {
      final data = await ApiService.getUser();
      _user = User.fromJson(data);
    } catch (_) {
      await ApiService.clearToken();
      _user = null;
    } finally {
      notifyListeners();
    }
  }
}
