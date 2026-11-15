
import 'dart:math' as math;

import 'package:maplibre_gl/maplibre_gl.dart';

import '../models/HikingRoute.dart';

class TrailEntryService {
  static LatLng? nearestPoint(
    HikingRoute route,
    LatLng userLocation,
  ) {
    final geometry = route.geometry;
    final type = geometry['type'];
    final coordinates = geometry['coordinates'];

    final List<List<dynamic>> lines = [];

    if (type == 'LineString' && coordinates is List) {
      lines.add(coordinates);
    } else if (type == 'MultiLineString' &&
        coordinates is List) {
      for (final line in coordinates) {
        if (line is List) {
          lines.add(line);
        }
      }
    }

    const earthRadius = 6371000.0;
    final cosLat =
        math.cos(userLocation.latitude * math.pi / 180);

    double x(double lon) =>
        (lon - userLocation.longitude) *
        math.pi / 180 *
        earthRadius *
        cosLat;

    double y(double lat) =>
        (lat - userLocation.latitude) *
        math.pi / 180 *
        earthRadius;

    double bestDistanceSquared = double.infinity;
    LatLng? bestPoint;

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

        final t = ((-ax * dx - ay * dy) / lengthSquared)
            .clamp(0.0, 1.0);

        final px = ax + t * dx;
        final py = ay + t * dy;

        final distanceSquared = px * px + py * py;

        if (distanceSquared < bestDistanceSquared) {
          bestDistanceSquared = distanceSquared;

          final lat = userLocation.latitude +
              (py / earthRadius) * 180 / math.pi;

          final lon = userLocation.longitude +
              (px / (earthRadius * cosLat)) *
                  180 /
                  math.pi;

          bestPoint = LatLng(lat, lon);
        }
      }
    }

    return bestPoint;
  }
}