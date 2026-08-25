import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MaxLengthEnforcement;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernow/core/utils/debouncer.dart';

// Whether the field currently has text - drives the clear (x) button's
// visibility. Only one CitySearchBar exists in this app (Search/Home), so a
// single autoDispose provider is fine; it resets when the widget unmounts.
final _hasTextProvider = StateProvider.autoDispose<bool>((ref) => false);

class CitySearchBar extends ConsumerStatefulWidget {
  final String? initialCity;
  final ValueChanged<String> onSubmittedCity;

  const CitySearchBar({super.key, this.initialCity, required this.onSubmittedCity});

  @override
  ConsumerState<CitySearchBar> createState() => _CitySearchBarState();
}

class _CitySearchBarState extends ConsumerState<CitySearchBar> {
  late final TextEditingController _controller;
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 600));

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCity ?? '');
    if (_controller.text.isNotEmpty) {
      // Deferred to after the first frame — ref.read(...notifier).state
      // triggers a rebuild, which can't happen mid-initState.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(_hasTextProvider.notifier).state = true;
      });
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    ref.read(_hasTextProvider.notifier).state = value.isNotEmpty;
    // Debounced so we don't fire a network call on every keystroke —
    // only after the user pauses typing for 600ms.
    _debouncer.run(() {
      if (value.trim().length >= 2) {
        widget.onSubmittedCity(value.trim());
      }
    });
  }

  void _clear() {
    _controller.clear();
    ref.read(_hasTextProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final hasText = ref.watch(_hasTextProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        // Defensive guard against pasting a huge block of text — not a
        // "valid city name" filter (real city names legitimately use
        // symbols/accents/non-Latin scripts, so we deliberately don't
        // restrict which characters are allowed here).
        maxLength: 85,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        onChanged: _onChanged,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) widget.onSubmittedCity(value.trim());
        },
        decoration: InputDecoration(
          counterText: '',
          hintText: 'Search for a city…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: hasText ? IconButton(icon: const Icon(Icons.clear), onPressed: _clear) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
