import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction over connectivity_plus so repositories/tests don't
/// depend on the plugin directly (loose coupling + easy mocking).
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  @override
  Stream<bool> get onConnectivityChanged =>
      connectivity.onConnectivityChanged.map(_hasConnection);

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
