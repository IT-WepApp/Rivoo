import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectionStatusIndicator extends StatefulWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  State<ConnectionStatusIndicator> createState() =>
      _ConnectionStatusIndicatorState();
}

class _ConnectionStatusIndicatorState extends State<ConnectionStatusIndicator> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription; // تعديل هنا

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus); // تعديل هنا
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    ConnectivityResult result; // تعديل هنا
    try {
      result = await _connectivity.checkConnectivity(); // تعديل هنا
    } catch (e) {
      // Handle error, e.g., log it
      return;
    }

    // If the widget is disposed before the future completes
    if (!mounted) {
      return;
    }

    return _updateConnectionStatus(result); // تعديل هنا
  }

  void _updateConnectionStatus(ConnectivityResult result) { // تعديل هنا
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _connectionStatus == ConnectivityResult.none
        ? const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off, color: Colors.red, size: 16),
              SizedBox(width: 4),
              Text("Offline", style: TextStyle(color: Colors.red)),
            ],
          )
        : const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi, color: Colors.green, size: 16),
              SizedBox(width: 4),
              Text("Online", style: TextStyle(color: Colors.green)),
            ],
          );
  }
}
