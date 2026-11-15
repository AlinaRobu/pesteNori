
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:maplibre_gl/maplibre_gl.dart';

import './models/HikingRoute.dart';
import './services/RouteDataService.dart';
import './map/TrailShieldRenderer.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapLibreMapController? _controller;
  TrailShieldRenderer? _renderer;

  String? _styleJson;
  String _status = 'Loading map...';

  bool _loadingRoutes = false;
  bool _routesLoaded = false;
  bool _downloading = false;

  double _downloadProgress = 0;

  int _routeCount = 0;
  int _visibleRouteCount = 0;

  HikingRoute? _selectedRoute;

  @override
  void initState() {
    super.initState();
    _loadStyle();
  }

  Future<void> _loadStyle() async {
    try {
      final text = await rootBundle.loadString(
        'assets/mapStyle.json',
      );

      jsonDecode(text);

      if (!mounted) return;

      setState(() {
        _styleJson = text;
        _status = 'Map style loaded';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _status = 'Map style error: $e';
      });
    }
  }

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
  }

  Future<void> _onStyleLoaded() async {
    final controller = _controller;
    if (controller == null) return;

    _renderer = TrailShieldRenderer(controller);

    _routesLoaded = false;
    _selectedRoute = null;

    await _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    final renderer = _renderer;

    if (renderer == null || _loadingRoutes) return;

    _loadingRoutes = true;

    if (mounted) {
      setState(() {
        _status = 'Loading hiking routes and symbols...';
      });
    }

    try {
      final routes = await RouteDataService().loadRoutes();

      final rendered = await renderer.displayRoutes(routes);

      if (!mounted) return;

      setState(() {
        _routeCount = routes.length;
        _visibleRouteCount = rendered;
        _routesLoaded = true;
        _status = 'Tap a hiking trail symbol';
      });
    } catch (e, stack) {
      debugPrint('ROUTE ERROR: $e');
      debugPrintStack(stackTrace: stack);

      if (!mounted) return;

      setState(() {
        _status = 'Route loading failed: $e';
      });
    } finally {
      _loadingRoutes = false;
    }
  }

  Future<void> _onMapClick( math.Point<double> point,LatLng coordinates) async {
    final controller = _controller;
    final renderer = _renderer;

    debugPrint('MAP TAPPED: $coordinates');
    debugPrint('SCREEN POINT: $point');

    if (controller == null || renderer == null || !_routesLoaded) {
      debugPrint('Map or routes not ready');
      return;
    }

    try {
      final layers = renderer.interactiveLayers;

      debugPrint('INTERACTIVE LAYERS: ${layers.length}');

      if (layers.isEmpty) {
        debugPrint('No interactive shield layers registered');
        return;
      }

      final features = await controller.queryRenderedFeatures(
        point,
        layers,
        null,
      );

      debugPrint('FEATURES FOUND: ${features.length}');

      if (features.isEmpty) {
        debugPrint('No shield detected at tap position');
        return;
      }

      for (final feature in features.take(3)) {
        debugPrint('TAPPED FEATURE: $feature');
      }

      final feature = features.first;

      if (feature is! Map) {
        debugPrint('Unexpected feature type: ${feature.runtimeType}');
        return;
      }

      final rawProperties = feature['properties'];

      if (rawProperties is! Map) {
        debugPrint('Feature has no properties: $feature');
        return;
      }

      final properties = Map<String, dynamic>.from(rawProperties);
      final id = properties['route_id']?.toString();

      debugPrint('ROUTE ID: $id');

      if (id == null || id.isEmpty) {
        debugPrint('Feature has no route_id');
        return;
      }

      final route = renderer.routeForId(id);

      if (route == null) {
        debugPrint('Route not found for ID: $id');
        return;
      }

      debugPrint('SELECTED ROUTE: ${route.name}');

      await renderer.selectRoute(route);

      if (!mounted) return;

      setState(() {
        _selectedRoute = route;
        _status = 'Selected: ${route.name}';
      });
    } catch (e, stackTrace) {
      debugPrint('MAP TAP ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _status = 'Tap error: $e';
      });
    }
  }

  Future<void> _clearSelection() async {
    await _renderer?.clearSelection();

    if (!mounted) return;

    setState(() {
      _selectedRoute = null;
      _status = 'Tap a hiking trail symbol';
    });
  }

  Widget _routePanel(HikingRoute route) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    route.name,
                    style: Theme.of(context)
                        .textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: _clearSelection,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            if (route.symbol != null)
              Text('Marking: ${route.symbol}'),

            if (route.from != null)
              Text('Start: ${route.from}'),

            if (route.to != null)
              Text('Destination: ${route.to}'),

            if (route.distanceKm != null)
              Text(
                'OSM distance: ${route.distanceKm} km',
              ),

            if (route.network != null)
              Text('Network: ${route.network}'),

            if (route.description != null &&
                route.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                route.description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.navigation),
                label: const Text('Follow this trail'),
                onPressed: () {
                  setState(() {
                    _status =
                        'Route highlighted. '
                        'GPS navigation is not implemented yet.';
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadBucegiRegion() async {
    if (kIsWeb) {
      setState(() {
        _status =
            'Offline regions require Android or iOS.';
      });
      return;
    }

    if (_downloading || _styleJson == null) return;

    setState(() {
      _downloading = true;
      _downloadProgress = 0;
      _status = 'Starting offline map download...';
    });

    try {
      final definition = OfflineRegionDefinition(
        bounds: LatLngBounds(
          southwest: const LatLng(45.25, 25.35),
          northeast: const LatLng(45.55, 25.65),
        ),
        minZoom: 9,
        maxZoom: 15,
        mapStyleUrl: _styleJson!,
        includeIdeographs: false,
      );

      await downloadOfflineRegion(
        definition,
        metadata: {
          'name': 'Bucegi',
          'country': 'Romania',
          'version': 1,
        },
        onEvent: (DownloadRegionStatus status) {
          if (!mounted) return;

          if (status is InProgress) {
            final total = status.requiredResourceCount;
            final completed = status.completedResourceCount;

            setState(() {
              _downloadProgress =
                  total > 0 ? completed / total : 0;

              _status =
                  'Downloading $completed / $total resources';
            });
          } else if (status is Success) {
            setState(() {
              _downloadProgress = 1;
              _downloading = false;
              _status = 'Bucegi offline map downloaded';
            });
          } else if (status is Error) {
            setState(() {
              _downloading = false;
              _status =
                  'Download failed: ${status.cause.message}';
            });
          }
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _downloading = false;
        _status = 'Offline download error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Romania Hiking Map'),
        actions: [
          IconButton(
            tooltip: 'Download Bucegi offline',
            onPressed: _downloading
                ? null
                : _downloadBucegiRegion,
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: _styleJson == null
          ? Center(
              child: Text(_status),
            )
          : Stack(
              children: [
                MapLibreMap(
                  styleString: _styleJson!,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(45.40, 25.45),
                    zoom: 11,
                  ),
                  onMapCreated: _onMapCreated,
                  onStyleLoadedCallback: _onStyleLoaded,
                  onMapClick: _onMapClick,
                  onMapLongClick: _onMapClick,
                  compassEnabled: true,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                ),

                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedRoute != null)
                        _routePanel(_selectedRoute!),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_status),

                              const SizedBox(height: 4),

                              Text(
                                '$_visibleRouteCount marked '
                                'routes / $_routeCount total',
                                style: Theme.of(context)
                                    .textTheme.labelSmall,
                              ),

                              if (_downloading) ...[
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: _downloadProgress > 0
                                      ? _downloadProgress
                                      : null,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}