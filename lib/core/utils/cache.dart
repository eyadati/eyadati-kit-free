import 'dart:async';

class CacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final Duration ttl;

  CacheEntry({
    required this.value,
    required this.createdAt,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().isAfter(createdAt.add(ttl));

  Duration get remainingTime {
    final expiry = createdAt.add(ttl);
    return expiry.difference(DateTime.now());
  }
}

class MemoryCache {
  static final MemoryCache _instance = MemoryCache._internal();
  factory MemoryCache() => _instance;
  MemoryCache._internal();

  final Map<String, CacheEntry> _cache = {};
  Timer? _cleanupTimer;

  void startCleanupTimer({Duration interval = const Duration(minutes: 5)}) {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(interval, (_) => _cleanup());
  }

  void stopCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  void _cleanup() {
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }

  void put<T>(String key, T value, {Duration ttl = const Duration(minutes: 5)}) {
    _cache[key] = CacheEntry(
      value: value,
      createdAt: DateTime.now(),
      ttl: ttl,
    );
  }

  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value as T;
  }

  bool contains(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void removeByPrefix(String prefix) {
    final keysToRemove = _cache.keys
        .where((key) => key.startsWith(prefix))
        .toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  void clear() {
    _cache.clear();
  }

  int get size => _cache.length;

  Duration? getRemainingTtl(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) return null;
    return entry.remainingTime;
  }
}

class CacheKeys {
  static const String doctors = 'doctors';
  static const String specialties = 'specialties';
  static const String cities = 'cities';

  static String doctor(String id) => 'doctor:$id';
  static String doctorsBySpecialty(String specialty) => 'doctors:specialty:$specialty';
  static String doctorsByCity(String city) => 'doctors:city:$city';
  static String doctorSlots(String doctorId, String date) => 'slots:$doctorId:$date';
  static String profile(String userId) => 'profile:$userId';
}
