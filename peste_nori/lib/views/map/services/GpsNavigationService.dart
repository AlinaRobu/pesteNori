
import 'dart:async';
import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

import '../models/HikingRoute.dart';

class TrailProgress {
  final double distanceFromTrailMeters;
  final double? remainingMeters;
  final double? routeLengthMeters;
  final double gpsAccuracyMeters;
  final bool offTrail;
  final bool progressAvailable;
  final double? forwardBearing;

  const TrailProgress({
    required this.distanceFromTrailMeters,
    required this.remainingMeters,
    required this.routeLengthMeters,
    required this.gpsAccuracyMeters,
    required this.offTrail,
    required this.progressAvailable,
    this.forwardBearing,
  });
}

class _Point {
  final double lat;
  final double lon;

  const _Point(this.lat, this.lon);
}

class GpsNavigationService {
  StreamSubscription<Position>? _subscription;

  Future<void> start({
    required HikingRoute route,
    required void Function(Position, TrailProgress) onUpdate,
    required void Function(Object) onError,
  }) async {
    await stop();

    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('Enable location services on your phone.');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError('Location permission is required.');
    }

    final parts = _extractParts(route.geometry);

    if (parts.isEmpty) {
      throw StateError('The selected route has no usable geometry.');
    }

    final settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      // Accept improved fixes while the hiker is standing still.
      distanceFilter: 0,
    );

    _subscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(
      (position) {
        try {
          onUpdate(position, _calculate(parts, position));
        } catch (error) {
          onError(error);
        }
      },
      onError: onError,
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  List<List<_Point>> _extractParts(
    Map<String, dynamic> geometry,
  ) {
    final type = geometry['type'];
    final raw = geometry['coordinates'];

    if (raw is! List) return [];

    final coordinateGroups = type == 'LineString'
        ? [raw]
        : type == 'MultiLineString'
            ? raw
            : <dynamic>[];

    final parts = <List<_Point>>[];

    for (final group in coordinateGroups) {
      if (group is! List) continue;

      final points = <_Point>[];

      for (final coordinate in group) {
        if (coordinate is! List || coordinate.length < 2) {
          continue;
        }

        final lon = coordinate[0];
        final lat = coordinate[1];

        if (lat is! num || lon is! num) continue;

        points.add(_Point(lat.toDouble(), lon.toDouble()));
      }

      if (points.length >= 2) {
        parts.add(points);
      }
    }

    return parts;
  }

  TrailProgress _calculate(
    List<List<_Point>> parts,
    Position position,
  ) {
    // Local metric projection around the current GPS position.
    // Suitable for calculating nearby trail distances.
    const earthRadius = 6371000.0;

    final latitudeRadians = position.latitude * math.pi / 180;
    final cosLatitude = math.cos(latitudeRadians);

    double x(_Point point) =>
        (point.lon - position.longitude) *
        math.pi / 180 * earthRadius * cosLatitude;

    double y(_Point point) =>
        (point.lat - position.latitude) *
        math.pi / 180 * earthRadius;

    double bestDistance = double.infinity;
    double bestAlong = 0;
    double totalLength = 0;
    double? trailBearing;
    double? approachBearing;

    // Progress is only unambiguous for a single ordered line.
    final canEstimateProgress = parts.length == 1;

    for (final part in parts) {
      double partLength = 0;

      for (var i = 0; i < part.length - 1; i++) {
        final ax = x(part[i]);
        final ay = y(part[i]);
        final bx = x(part[i + 1]);
        final by = y(part[i + 1]);

        final dx = bx - ax;
        final dy = by - ay;

        final lengthSquared = dx * dx + dy * dy;
        if (lengthSquared == 0) continue;

        final t = ((-ax * dx - ay * dy) / lengthSquared)
            .clamp(0.0, 1.0);

        final closestX = ax + t * dx;
        final closestY = ay + t * dy;

        final distance = math.sqrt(
          closestX * closestX + closestY * closestY,
        );

        final length = math.sqrt(lengthSquared);

        if (distance < bestDistance) {
          bestDistance = distance;
          bestAlong = partLength + length * t;
          trailBearing = math.atan2(dx, dy) * 180 / math.pi;
          approachBearing = math.atan2(closestX, closestY) * 180 / math.pi;
        }

        partLength += length;
      }

      totalLength += partLength;
    }

    final accuracy = position.accuracy;

    // Only flag off-trail when GPS uncertainty does not
    // reasonably explain the measured displacement.
    final offTrail =
        accuracy <= 50 &&
        bestDistance - accuracy > 40;

    return TrailProgress(
      distanceFromTrailMeters: bestDistance,
      remainingMeters: canEstimateProgress
          ? math.max(0, totalLength - bestAlong)
          : null,
      routeLengthMeters: canEstimateProgress
          ? totalLength
          : null,
      gpsAccuracyMeters: accuracy,
      offTrail: offTrail,
      progressAvailable: canEstimateProgress,
      forwardBearing: offTrail ? approachBearing : trailBearing,
    );
  }
}
