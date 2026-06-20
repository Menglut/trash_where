import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchService {
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxItems = 10;

  Future<List<String>> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentSearchesKey) ?? const [];
  }

  Future<List<String>> addSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return loadRecentSearches();
    }

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_recentSearchesKey) ?? const [];
    final next = [
      trimmed,
      ...current.where((item) => item != trimmed),
    ].take(_maxItems).toList(growable: false);

    await prefs.setStringList(_recentSearchesKey, next);
    return next;
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
  }
}
