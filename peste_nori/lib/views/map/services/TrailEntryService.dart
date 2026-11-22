import 'dart:math' as math;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../models/HikingRoute.dart';

class TrailEntryService {
  static Future<List<LatLng>?> walkingApproach(
    HikingRoute route,
    LatLng userLocation,
  ) async {
    final entries = _nearbyPoints(route, userLocation);
    if (entries.isEmpty) return null;

    final function = FirebaseFunctions.instanceFor(region: 'europe-west1')
        .httpsCallable(
          'walkingApproach',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 20)),
        );
    final result = await function.call<Map<String, dynamic>>({
      'start': [userLocation.longitude, userLocation.latitude],
      'entries': [
        for (final entry in entries) [entry.longitude, entry.latitude],
      ],
    });
    final coordinates = result.data['coordinates'] as List?;
    return coordinates?.map((point) {
      final pair = point as List;
      return LatLng((pair[1] as num).toDouble(), (pair[0] as num).toDouble());
    }).toList();
  }

  static List<LatLng> _nearbyPoints(HikingRoute route, LatLng userLocation) {
    final geometry = route.geometry;
    final type = geometry['type'];
    final coordinates = geometry['coordinates'];

    final List<List<dynamic>> lines = [];

    if (type == 'LineString' && coordinates is List) {
      lines.add(coordinates);
    } else if (type == 'MultiLineString' && coordinates is List) {
      for (final line in coordinates) {
        if (line is List) {
          lines.add(line);
        }
      }
    }

    const earthRadius = 6371000.0;
    final cosLat = math.cos(userLocation.latitude * math.pi / 180);

    double x(double lon) =>
        (lon - userLocation.longitude) * math.pi / 180 * earthRadius * cosLat;

    double y(double lat) =>
        (lat - userLocation.latitude) * math.pi / 180 * earthRadius;

    final projections = <({double x, double y, double distanceSquared})>[];

    for (final line in lines) {
      for (var i = 0; i < line.length - 1; i++) {
        final a = line[i];
        final b = line[i + 1];

        if (a is! List ||
            b is! List ||
            a.length < 2 ||
            b.length < 2 ||
            a[0] is! num ||
            a[1] is! num ||
            b[0] is! num ||
            b[1] is! num) {
          continue;
        }

        final ax = x((a[0] as num).toDouble());
        final ay = y((a[1] as num).toDouble());
        final bx = x((b[0] as num).toDouble());
        final by = y((b[1] as num).toDouble());

        final dx = bx - ax;
        final dy = by - ay;

        final lengthSquared = dx * dx + dy * dy;
        if (lengthSquared == 0) continue;

        final t = ((-ax * dx - ay * dy) / lengthSquared).clamp(0.0, 1.0);

        final px = ax + t * dx;
        final py = ay + t * dy;

        projections.add((x: px, y: py, distanceSquared: px * px + py * py));
      }
    }

    projections.sort((a, b) => a.distanceSquared.compareTo(b.distanceSquared));
    final candidates = <({double x, double y})>[];
    for (final point in projections) {
      final tooClose = candidates.any((candidate) {
        final dx = point.x - candidate.x;
        final dy = point.y - candidate.y;
        return dx * dx + dy * dy < 75 * 75;
      });
      if (tooClose) continue;
      candidates.add((x: point.x, y: point.y));
      if (candidates.length == 3) break;
    }

    return candidates.map((point) {
      final latitude =
          userLocation.latitude + point.y / earthRadius * 180 / math.pi;
      final longitude =
          userLocation.longitude +
          point.x / (earthRadius * cosLat) * 180 / math.pi;
      return LatLng(latitude, longitude);
    }).toList();
  }
}
