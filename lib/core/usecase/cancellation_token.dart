/// Domain-layer cancellation handle. Exists so use cases/repositories can
/// accept a cancellable request without domain ever importing Dio's
/// CancelToken directly — the data layer bridges this to a real Dio
/// CancelToken (see WeatherRemoteDataSource).
class CancellationToken {
  bool _isCancelled = false;
  final List<void Function()> _listeners = [];

  bool get isCancelled => _isCancelled;

  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Data layer hooks in here to forward cancellation to its own
  /// framework-specific cancel token.
  void onCancel(void Function() listener) {
    if (_isCancelled) {
      listener();
    } else {
      _listeners.add(listener);
    }
  }
}
