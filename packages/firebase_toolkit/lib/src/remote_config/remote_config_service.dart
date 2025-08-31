import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final _rc = FirebaseRemoteConfig.instance;

  Future<void> init({Duration minFetch = const Duration(hours: 1)}) async {
    await _rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: minFetch,
    ));
    await _rc.fetchAndActivate();
  }

  String getString(String key, {String fallback = ''}) =>
      _rc.getString(key).isEmpty ? fallback : _rc.getString(key);
}
