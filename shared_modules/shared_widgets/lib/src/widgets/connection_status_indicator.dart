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
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      // Handle error, e.g., log it
      return;
    }

    // If the widget is disposed before the future completes
    if (!mounted) {
      return;
    }

    return _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    // Use the first result or determine status based on the list
    ConnectivityResult currentStatus =
        result.isNotEmpty ? result[0] : ConnectivityResult.none;
    if (result.contains(ConnectivityResult.none)) {
      currentStatus = ConnectivityResult.none;
    }
    setState(() {
      _connectionStatus = currentStatus;
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
