import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/HikingRoute.dart';

class RouteDataService {
  Future<List<HikingRoute>> loadRoutes() async {
    final asset = await rootBundle.load('assets/hiking_routes.geojson');
    final bytes = asset.buffer.asUint8List(
      asset.offsetInBytes,
      asset.lengthInBytes,
    );
    return compute(_parseRoutes, bytes, debugLabel: 'Parse hiking routes');
  }
}

List<HikingRoute> _parseRoutes(Uint8List bytes) {
  final data = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  final features = data['features'] as List<dynamic>;
  return features
      .cast<Map<String, dynamic>>()
      .map(HikingRoute.fromFeature)
      .toList();
}
