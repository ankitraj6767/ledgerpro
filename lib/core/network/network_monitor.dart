import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final networkMonitorProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged
      .map((result) => result.any((item) => item != ConnectivityResult.none))
      // The connectivity_plus platform channel can emit stream errors on
      // Windows (e.g. transient adapter/native failures). Swallow them so a
      // monitoring glitch never surfaces as an unhandled stream error to
      // watchers, which on desktop can escalate into an app crash.
      .handleError((Object _) {});
});
