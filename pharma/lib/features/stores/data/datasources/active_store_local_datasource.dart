import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';

class ActiveStoreLocalDataSource {
  ActiveStoreLocalDataSource(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'active_store_id';
  final _controller = StreamController<String?>.broadcast();

  String? getActiveStoreId() => _prefs.getString(_key);

  Future<void> setActiveStoreId(String id) async {
    try {
      await _prefs.setString(_key, id);
      _controller.add(id);
    } catch (e) { throw CacheException(e.toString()); }
  }

  Stream<String?> watchActiveStoreId() async* {
    yield _prefs.getString(_key);
    yield* _controller.stream;
  }
}