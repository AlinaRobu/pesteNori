
import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/HikingRoute.dart';

class RouteDataService {
  Future<List<HikingRoute>> loadRoutes() async {
    final jsonString =
        await rootBundle.loadString('assets/export.geojson');

    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final features = data['features'] as List<dynamic>;

    final routes = <HikingRoute>[];

    for (final item in features) {
      final feature = Map<String, dynamic>.from(item);
      final properties =
          Map<String, dynamic>.from(feature['properties'] ?? {});

      // Only actual hiking route relations.
      if (properties['type'] != 'route') continue;

      final routeType = properties['route']?.toString();

      if (!['hiking', 'foot', 'walking'].contains(routeType)) {
        continue;
      }

      final route = HikingRoute.fromFeature(feature);

      if (!route.hasGeometry) continue;

      routes.add(route);
    }

    return routes;
  }
}
