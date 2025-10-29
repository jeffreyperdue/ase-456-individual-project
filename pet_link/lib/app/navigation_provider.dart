import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navIndexProvider = StateNotifierProvider<NavIndexNotifier, int>((ref) {
  final notifier = NavIndexNotifier();
  notifier.initialize();
  return notifier;
});

class NavIndexNotifier extends StateNotifier<int> {
  NavIndexNotifier() : super(0);

  static const _prefsKey = 'nav_selected_index';
  bool _hasExplicitOverride = false;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt(_prefsKey);
      if (!_hasExplicitOverride && saved != null && saved >= 0 && saved <= 2) {
        state = saved;
      }
    } catch (_) {
      // ignore persistence failures
    }
  }

  void setIndex(int index) {
    if (index == state) return;
    state = index;
    _persist(index);
  }

  /// Explicitly set index due to an incoming route (deep link). This
  /// should take precedence over any persisted value.
  void setIndexFromRoute(int index) {
    _hasExplicitOverride = true;
    setIndex(index);
  }

  Future<void> _persist(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKey, index);
    } catch (_) {
      // ignore persistence failures
    }
  }
}


