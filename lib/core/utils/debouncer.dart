import 'dart:async';

/// Simple debouncer used by the search bar so we don't fire an
/// API call on every keystroke. Call [run] on every onChanged;
/// only the last call within [delay] actually executes.
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
