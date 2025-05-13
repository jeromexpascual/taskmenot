import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _subscription;

  ConnectivityProvider() {
    _initialize();
  }

  void _initialize() async {
    _checkConnection();
    _subscription = _connectivity.onConnectivityChanged.listen((_) => _checkConnection());
  }

  Future<void> _checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
