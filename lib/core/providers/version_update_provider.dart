import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_version.dart';
import '../utils/supabase_client.dart';

class VersionUpdateState {
  final int? remoteBuildNumber;
  final String? remoteVersion;
  final bool forceUpdate;
  final String? changelog;
  final bool isLoading;
  final bool checked;

  const VersionUpdateState({
    this.remoteBuildNumber,
    this.remoteVersion,
    this.forceUpdate = false,
    this.changelog,
    this.isLoading = false,
    this.checked = false,
  });

  bool get isUpdateAvailable =>
      checked && remoteBuildNumber != null && remoteBuildNumber! > currentBuildNumber;

  VersionUpdateState copyWith({
    int? remoteBuildNumber,
    String? remoteVersion,
    bool? forceUpdate,
    String? changelog,
    bool? isLoading,
    bool? checked,
  }) {
    return VersionUpdateState(
      remoteBuildNumber: remoteBuildNumber ?? this.remoteBuildNumber,
      remoteVersion: remoteVersion ?? this.remoteVersion,
      forceUpdate: forceUpdate ?? this.forceUpdate,
      changelog: changelog ?? this.changelog,
      isLoading: isLoading ?? this.isLoading,
      checked: checked ?? this.checked,
    );
  }
}

final versionUpdateProvider = StateNotifierProvider<VersionUpdateNotifier, VersionUpdateState>((ref) {
  return VersionUpdateNotifier();
});

class VersionUpdateNotifier extends StateNotifier<VersionUpdateState> {
  RealtimeChannel? _channel;
  Timer? _pollTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;

  SupabaseClient get _client => SupabaseInitializer.client;

  VersionUpdateNotifier() : super(const VersionUpdateState(isLoading: true)) {
    _init();
  }

  void _init() {
    _fetchAndSubscribe();
    _startPolling();
  }

  void _processRow(Map<String, dynamic> row) {
    final buildNumber = (row['build_number'] as num?)?.toInt();
    if (buildNumber == null) return;

    state = state.copyWith(
      remoteBuildNumber: buildNumber,
      remoteVersion: row['version'] as String?,
      forceUpdate: row['force_update'] as bool? ?? false,
      changelog: row['changelog'] as String?,
      isLoading: false,
      checked: true,
    );
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _pollSupabaseVersion();
    });
  }

  Future<void> _pollSupabaseVersion() async {
    try {
      final response = await _client
          .from('app_versions')
          .select('*')
          .limit(1)
          .maybeSingle();
      if (response != null) {
        _processRow(response);
      }
    } catch (_) {}
  }

  Future<void> _fetchAndSubscribe() async {
    try {
      final response = await _client
          .from('app_versions')
          .select('*')
          .limit(1)
          .maybeSingle();

      if (response != null) {
        _processRow(response);
      } else {
        state = state.copyWith(isLoading: false, checked: true);
      }
    } catch (e) {
      debugPrint('VersionUpdate: fetch error: $e');
      state = state.copyWith(isLoading: false, checked: true);
    }

    _subscribeToRealtime();
  }

  void _subscribeToRealtime() {
    _channel?.unsubscribe();
    _channel = _client
        .channel('app_versions')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'app_versions',
          callback: (payload) {
            _processRow(payload.newRecord);
          },
        )
        .subscribe((status, error) {
          if (error != null) {
            debugPrint('VersionUpdate: Realtime error: $error');
          }
          if (status == RealtimeSubscribeStatus.channelError ||
              status == RealtimeSubscribeStatus.timedOut) {
            _scheduleReconnect();
          }
        });
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) return;
    _reconnectAttempts++;
    final delay = Duration(
      seconds: (_reconnectAttempts * 2).clamp(1, 30),
    );
    Future.delayed(delay, () {
      if (mounted) _subscribeToRealtime();
    });
  }

  void reconnect() {
    _reconnectAttempts = 0;
    _subscribeToRealtime();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _channel?.unsubscribe();
    super.dispose();
  }
}
