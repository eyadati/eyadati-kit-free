({double? lat, double? lng}) parseGoogleMapsLink(String url) {
  final latLngRegExp1 = RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)');
  final match1 = latLngRegExp1.firstMatch(url);
  if (match1 != null) {
    return (
      lat: double.tryParse(match1.group(1)!),
      lng: double.tryParse(match1.group(2)!),
    );
  }

  final uri = Uri.tryParse(url);
  if (uri == null) return (lat: null, lng: null);

  final latStr = uri.queryParameters['q'] ?? uri.queryParameters['ll'];
  if (latStr != null) {
    final parts = latStr.split(',');
    if (parts.length == 2) {
      return (
        lat: double.tryParse(parts[0].trim()),
        lng: double.tryParse(parts[1].trim()),
      );
    }
  }

  final query = uri.queryParameters['query'];
  if (query != null) {
    final parts = query.split(',');
    if (parts.length == 2) {
      return (
        lat: double.tryParse(parts[0].trim()),
        lng: double.tryParse(parts[1].trim()),
      );
    }
  }

  return (lat: null, lng: null);
}
