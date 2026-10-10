import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(true);
  bool _simulatedOffline = false;

  bool get isConnected => !_simulatedOffline && isConnectedNotifier.value;

  void setSimulatedOffline(bool offline) {
    _simulatedOffline = offline;
    isConnectedNotifier.value = !offline;
  }

  Future<bool> checkConnectivity() async {
    if (_simulatedOffline) {
      isConnectedNotifier.value = false;
      return false;
    }

    try {
      final result = await InternetAddress.lookup('dns.google')
          .timeout(const Duration(seconds: 3));
      final connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      isConnectedNotifier.value = connected;
      return connected;
    } catch (_) {
      if (kIsWeb) {
        isConnectedNotifier.value = true;
        return true;
      }
      isConnectedNotifier.value = false;
      return false;
    }
  }
}
