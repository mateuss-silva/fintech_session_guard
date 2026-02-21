import 'package:shared_preferences/shared_preferences.dart';

abstract class WatchlistLocalDataSource {
  Future<List<String>> getWatchlist();
  Future<void> addTicker(String ticker);
  Future<void> removeTicker(String ticker);
}

class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  static const String _watchlistKey = 'user_watchlist';
  final SharedPreferences sharedPreferences;

  WatchlistLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<String>> getWatchlist() async {
    return sharedPreferences.getStringList(_watchlistKey) ?? [];
  }

  @override
  Future<void> addTicker(String ticker) async {
    final list = await getWatchlist();
    if (!list.contains(ticker)) {
      list.add(ticker);
      await sharedPreferences.setStringList(_watchlistKey, list);
    }
  }

  @override
  Future<void> removeTicker(String ticker) async {
    final list = await getWatchlist();
    if (list.contains(ticker)) {
      list.remove(ticker);
      await sharedPreferences.setStringList(_watchlistKey, list);
    }
  }
}
