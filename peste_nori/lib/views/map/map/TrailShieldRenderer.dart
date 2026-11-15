
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../models/HikingRoute.dart';
import '../models/TrailSymbol.dart';

class TrailShieldRenderer {
  static const routeSource = 'hiking-shield-routes';
  static const selectedSource = 'hiking-selected-route';
  static const selectedLayer = 'hiking-selected-line';

  final MapLibreMapController controller;

  final Map<String, HikingRoute> routesById = {};
  final Set<String> _layerIds = {};

  bool _selectionExists = false;

  TrailShieldRenderer(this.controller);

  List<String> get interactiveLayers =>
      _layerIds.toList(growable: false);

  HikingRoute? routeForId(String id) => routesById[id];

  String? _keyFor(TrailSymbol symbol) {
    final color = symbol.markingColor.toLowerCase();

    var shape = symbol.shape.toLowerCase();

    if (shape == 'stripe') shape = 'bar';
    if (shape == 'circle') shape = 'dot';

    const colors = {
      'red',
      'blue',
      'yellow',
      'green',
      'black',
      'white',
      'orange',
      'purple',
    };

    const shapes = {
      'bar',
      'triangle',
      'cross',
      'dot',
      'diamond',
      'square',
    };

    if (!colors.contains(color)) return null;
    if (!shapes.contains(shape)) return null;

    return '${color}_$shape';
  }

  Future<int> displayRoutes(
    List<HikingRoute> routes,
  ) async {
    final features = <Map<String, dynamic>>[];
    final keys = <String>{};

    routesById.clear();
    _layerIds.clear();

    for (final route in routes) {
      routesById[route.id] = route;

      if (!route.hasSymbol || !route.hasGeometry) {
        continue;
      }

      final symbol = TrailSymbol.parse(route.symbol!);
      final key = _keyFor(symbol);

      if (key == null) continue;

      keys.add(key);

      features.add({
        'type': 'Feature',
        'id': route.id,
        'properties': {
          'route_id': route.id,
          'shield_key': key,
        },
        'geometry': route.geometry,
      });
    }

    // Add images before creating symbol layers.
    for (final key in keys) {
      final bytes = await _generateShield(key);

      await controller.addImage(
        'trail-shield-$key',
        bytes,
      );
    }

    await controller.addGeoJsonSource(
      routeSource,
      {
        'type': 'FeatureCollection',
        'features': features,
      },
    );

    for (final key in keys) {
      final layerId = 'trail-shield-layer-$key';

      await controller.addSymbolLayer(
        routeSource,
        layerId,
        SymbolLayerProperties(
          iconImage: 'trail-shield-$key',
          iconSize: 0.55,
          iconAllowOverlap: false,
          iconIgnorePlacement: false,
          symbolPlacement: 'line',
          symbolSpacing: 180,
        ),
        filter: [
          '==',
          ['get', 'shield_key'],
          key,
        ],
        minzoom: 10,
      );

      _layerIds.add(layerId);
    }

    return features.length;
  }

  Future<void> selectRoute(HikingRoute route) async {
    if (_selectionExists) {
      await controller.removeLayer(selectedLayer);
      await controller.removeSource(selectedSource);
      _selectionExists = false;
    }

    await controller.addGeoJsonSource(
      selectedSource,
      {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'properties': {
              'route_id': route.id,
            },
            'geometry': route.geometry,
          },
        ],
      },
    );

    await controller.addLineLayer(
        selectedSource,
        selectedLayer,
        const LineLayerProperties(
            lineColor: '#FF6D00',
            lineWidth: 7,
            lineOpacity: 1.0,
            lineCap: 'round',
            lineJoin: 'round',
        ),
    );

    _selectionExists = true;
  }

  Future<void> clearSelection() async {
    if (!_selectionExists) return;

    await controller.removeLayer(selectedLayer);
    await controller.removeSource(selectedSource);

    _selectionExists = false;
  }

  Color _color(String name) {
    switch (name) {
      case 'red':
        return const Color(0xFFD62828);
      case 'blue':
        return const Color(0xFF1565C0);
      case 'yellow':
        return const Color(0xFFFFD600);
      case 'green':
        return const Color(0xFF2E7D32);
      case 'orange':
        return const Color(0xFFEF6C00);
      case 'purple':
        return const Color(0xFF7B1FA2);
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      default:
        return Colors.grey;
    }
  }

  Future<Uint8List> _generateShield(String key) async {
    const size = 64.0;

    final separator = key.indexOf('_');
    final colorName = key.substring(0, separator);
    final shape = key.substring(separator + 1);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final background = Paint()..color = Colors.white;

    final outline = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final symbolPaint = Paint()
      ..color = _color(colorName)
      ..style = PaintingStyle.fill;

    final shield = RRect.fromRectAndRadius(
      const Rect.fromLTWH(4, 4, 56, 56),
      const Radius.circular(5),
    );

    canvas.drawRRect(shield, background);
    canvas.drawRRect(shield, outline);

    switch (shape) {
      case 'bar':
        canvas.drawRect(
          const Rect.fromLTWH(12, 25, 40, 14),
          symbolPaint,
        );
        break;

      case 'triangle':
        final path = Path()
          ..moveTo(32, 11)
          ..lineTo(52, 50)
          ..lineTo(12, 50)
          ..close();
        canvas.drawPath(path, symbolPaint);
        break;

      case 'cross':
        canvas.drawRect(
          const Rect.fromLTWH(26, 12, 12, 40),
          symbolPaint,
        );
        canvas.drawRect(
          const Rect.fromLTWH(12, 26, 40, 12),
          symbolPaint,
        );
        break;

      case 'dot':
        canvas.drawCircle(
          const Offset(32, 32),
          15,
          symbolPaint,
        );
        break;

      case 'diamond':
        final path = Path()
          ..moveTo(32, 10)
          ..lineTo(54, 32)
          ..lineTo(32, 54)
          ..lineTo(10, 32)
          ..close();
        canvas.drawPath(path, symbolPaint);
        break;

      case 'square':
        canvas.drawRect(
          const Rect.fromLTWH(16, 16, 32, 32),
          symbolPaint,
        );
        break;
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(64, 64);

    final data = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    image.dispose();
    picture.dispose();

    if (data == null) {
      throw StateError('Could not create shield $key');
    }

    return data.buffer.asUint8List();
  }
}
