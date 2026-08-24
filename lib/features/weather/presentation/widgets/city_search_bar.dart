import 'package:flutter/material.dart';
import '../../../../core/utils/debouncer.dart';

class CitySearchBar extends StatefulWidget {
  final String? initialCity;
  final ValueChanged<String> onSubmittedCity;

  const CitySearchBar({super.key, this.initialCity, required this.onSubmittedCity});

  @override
  State<CitySearchBar> createState() => _CitySearchBarState();
}

class _CitySearchBarState extends State<CitySearchBar> {
  late final TextEditingController _controller;
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 600));

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCity ?? '');
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    // Debounced so we don't fire a network call on every keystroke —
    // only after the user pauses typing for 600ms.
    _debouncer.run(() {
      if (value.trim().length >= 2) {
        widget.onSubmittedCity(value.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onChanged: _onChanged,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) widget.onSubmittedCity(value.trim());
        },
        decoration: InputDecoration(
          hintText: 'Search for a city…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _controller.clear()),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
