
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';

import './models/HikingRoute.dart';
import './services/RouteDataService.dart';
import './services/GpsNavigationService.dart';
import './services/TrailEntryService.dart';
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

  final GpsNavigationService _gpsService = GpsNavigationService();

  bool _isNavigating = false;
  bool _startingNavigation = false;
  bool _followCamera = true;
  final _mapKey = GlobalKey();
  final _navigationPanelKey = GlobalKey();
  EdgeInsets _navigationInsets = EdgeInsets.zero;
  List<LatLng>? _walkingApproach;
  bool _navigationCameraScheduled = false;

  Position? _currentPosition;
  TrailProgress? _trailProgress;
  bool _navigationExpanded = false;

  static const String _entrySourceId = 'trail-entry-source';
  static const String _entryLayerId = 'trail-entry-line';

  int _navigationSession = 0;
  int? _visibleApproachSession;

  bool _locationPermissionGranted = false;
  bool _centerOnFirstLocation = true;

  @override
  void initState() {
    super.initState();
    _requestMapLocationPermission();
    _loadStyle();
  }

  @override
  void dispose() {
    _gpsService.stop();
    super.dispose();
  }

  Future<void> _requestMapLocationPermission() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (!mounted) return;
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (!mounted) return;
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        setState(() => _locationPermissionGranted = true);
      }
    } catch (e) {
      debugPrint('Map location permission error: $e');
    }
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

  Future<void> _onUserLocationUpdated(UserLocation location) async {
    final controller = _controller;
    if (controller == null || !_centerOnFirstLocation) return;
    _centerOnFirstLocation = false;
    if (_isNavigating || _selectedRoute != null) return;

    try {
      await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: location.position, zoom: 14, tilt: 35),
        ),
      );
    } catch (e) {
      debugPrint('Initial map camera move failed: $e');
    }
  }

  Future<void> _onStyleLoaded() async {
    final controller = _controller;
    if (controller == null) return;

    _renderer = TrailShieldRenderer(controller);
    _visibleApproachSession = null;

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

      if (_isNavigating) {
        await _stopNavigation();
      }
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
    if (_selectedRoute == null) return;
    setState(() => _selectedRoute = null);
    await _stopNavigation();

    if (!mounted || _selectedRoute != null) return;
    await _renderer?.clearSelection();

    if (!mounted || _selectedRoute != null) return;
    setState(() => _status = 'Tap a hiking trail symbol');
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
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: Icon(
                    _isNavigating ? Icons.stop : Icons.navigation,
                  ),
                  label: Text(
                    _startingNavigation
                        ? 'Starting GPS...'
                        : _isNavigating
                            ? 'Stop navigation'
                            : 'Follow this trail',
                  ),
                  onPressed: _startingNavigation
                      ? null
                      : _isNavigating
                          ? _clearSelection
                          : _startNavigation,
                ),
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

  Future<void> _startNavigation() async {
    final route = _selectedRoute;

    if (route == null || _startingNavigation) return;

    _followCamera = true;
    _navigationExpanded = false;
    _walkingApproach = null;
    final session = ++_navigationSession;
    var approachRequested = false;

    setState(() {
      _startingNavigation = true;
      _status = 'Starting GPS tracking...';
    });

    try {
      await _gpsService.start(
        route: route,
        onUpdate: (position, progress) {
          if (!mounted || session != _navigationSession) return;

          setState(() {
            _currentPosition = position;
            _trailProgress = progress;
            _isNavigating = true;
            _status = progress.offTrail
                ? 'Warning: You may be off the trail'
                : 'Following ${route.name}';
          });

          if (progress.offTrail && !approachRequested) {
            approachRequested = true;
            _showConnectionToTrail(
              LatLng(position.latitude, position.longitude),
              route,
              session,
            );
          }
          _scheduleNavigationCamera();
        },
        onError: (error) {
          if (!mounted || session != _navigationSession) return;

          setState(() {
            _status = 'GPS error: $error';
          });
        },
      );

      if (!mounted || session != _navigationSession) {
        await _gpsService.stop();
        return;
      }

      setState(() {
        _isNavigating = true;
      });
    } catch (e) {
      if (!mounted || session != _navigationSession) return;

      setState(() {
        _status = 'Cannot start navigation: $e';
        _isNavigating = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _startingNavigation = false;
        });
      }
    }
  }

  Future<void> _stopNavigation() async {
    _navigationSession++;
    _followCamera = false;
    _walkingApproach = null;
    final approachSession = _visibleApproachSession;
    _visibleApproachSession = null;
    await _gpsService.stop();

    if (!mounted) return;
    await _clearNavigationInsets();
    if (!mounted) return;
    final controller = _controller;
    if (approachSession != null && controller != null) {
      await controller.removeLayer('$_entryLayerId-$approachSession');
      await controller.removeSource('$_entrySourceId-$approachSession');
    }

    if (!mounted) return;
    setState(() {
      _isNavigating = false;
      _currentPosition = null;
      _trailProgress = null;
      _status = 'Navigation stopped';
    });
  }

  Widget _navigationPanel() {
    final progress = _trailProgress;

    if (!_isNavigating) {
      return const SizedBox.shrink();
    }

    return Card(
      key: _navigationPanelKey,
      elevation: 4,
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Always visible: compact navigation bar
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _navigationExpanded = !_navigationExpanded;
              });
              _scheduleNavigationCamera();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.navigation,
                    size: 18,
                    color: Colors.deepOrange,
                  ),
                  const SizedBox(width: 8),

                  const Expanded(
                    child: Text(
                      'Trail navigation',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  if (progress?.offTrail == true)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: Colors.deepOrange,
                      ),
                    ),

                  Icon(
                    _navigationExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // Only visible when expanded
          if (_navigationExpanded) ...[
            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                12, 8, 12, 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (progress == null)
                    const Text(
                      'Waiting for GPS...',
                      style: TextStyle(fontSize: 12),
                    )
                  else ...[
                    Text(
                      'Distance from trail: '
                      '${progress.distanceFromTrailMeters.toStringAsFixed(0)} m',
                      style: const TextStyle(fontSize: 12),
                    ),

                    Text(
                      'GPS accuracy: '
                      '±${progress.gpsAccuracyMeters.toStringAsFixed(0)} m',
                      style: const TextStyle(fontSize: 12),
                    ),

                    if (progress.remainingMeters != null)
                      Text(
                        'Estimated remaining: '
                        '${(progress.remainingMeters! / 1000).toStringAsFixed(2)} km',
                        style: const TextStyle(fontSize: 12),
                      ),

                    if (progress.offTrail)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Warning: You may be off the trail',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],

                  const SizedBox(height: 6),

                  // Compact icon controls
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        tooltip: 'Follow GPS',
                        onPressed: () {
                          setState(() {
                            _followCamera = !_followCamera;
                          });
                          if (_followCamera) {
                            _scheduleNavigationCamera();
                          } else {
                            _clearNavigationInsets();
                          }
                        },
                        icon: Icon(
                          _followCamera
                              ? Icons.gps_fixed
                              : Icons.gps_not_fixed,
                          size: 20,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),

                      IconButton(
                        tooltip: 'Show trail',
                        onPressed: () async {
                          setState(() {
                            _followCamera = false;
                            _navigationExpanded = false;
                          });
                          await _clearNavigationInsets();
                          if (mounted) await _zoomToSelectedRoute();
                        },
                        icon: const Icon(
                          Icons.route,
                          size: 20,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),

                      IconButton(
                        tooltip: 'My location',
                        onPressed: () async {
                          setState(() {
                            _followCamera = false;
                            _navigationExpanded = false;
                          });
                          await _clearNavigationInsets();
                          if (mounted) await _goToMyLocation();
                        },
                        icon: const Icon(
                          Icons.my_location,
                          size: 20,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),

                      IconButton(
                        tooltip: 'Stop navigation',
                        onPressed: _clearSelection,
                        icon: const Icon(
                          Icons.stop_circle_outlined,
                          size: 20,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _zoomToSelectedRoute() async {
    final route = _selectedRoute;
    final controller = _controller;

    if (route == null || controller == null) return;

    final geometry = route.geometry;
    final type = geometry['type'];
    final coordinates = geometry['coordinates'];

    final List<dynamic> points = [];

    if (type == 'LineString') {
      points.addAll(coordinates as List);
    } else if (type == 'MultiLineString') {
      for (final line in coordinates as List) {
        points.addAll(line as List);
      }
    }

    if (points.isEmpty) return;

    double minLat = 90;
    double maxLat = -90;
    double minLon = 180;
    double maxLon = -180;

    for (final point in points) {
      if (point is! List || point.length < 2) continue;

      final lon = (point[0] as num).toDouble();
      final lat = (point[1] as num).toDouble();

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lon < minLon) minLon = lon;
      if (lon > maxLon) maxLon = lon;
    }

    if (minLat > maxLat || minLon > maxLon) return;

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLon),
          northeast: LatLng(maxLat, maxLon),
        ),
        left: 45,
        top: 100,
        right: 45,
        bottom: 260,
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    final position = _currentPosition;

    if (position == null || _controller == null) return;

    await _controller!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            position.latitude,
            position.longitude,
          ),
          zoom: 15,
        ),
      ),
    );
  }


  Future<void> _showConnectionToTrail(
    LatLng userLocation,
    HikingRoute route,
    int session,
  ) async {
    final controller = _controller;
    if (controller == null) return;
    final renderer = _renderer;

    bool isCurrent() =>
        mounted && session == _navigationSession && renderer == _renderer;
    final source = '$_entrySourceId-$session';
    final layer = '$_entryLayerId-$session';
    var sourceAdded = false;
    var layerAdded = false;
    var approachShown = false;
    try {
      final approach = await TrailEntryService.walkingApproach(
        route,
        userLocation,
      );
      if (!isCurrent() || _trailProgress?.offTrail != true) return;
      if (approach != null) {
        await controller.addGeoJsonSource(source, {
          'type': 'FeatureCollection',
          'features': [
            {
              'type': 'Feature',
              'properties': <String, dynamic>{},
              'geometry': {
                'type': 'LineString',
                'coordinates': [
                  for (final point in approach)
                    [point.longitude, point.latitude],
                ],
              },
            },
          ],
        });
        sourceAdded = true;
        if (!isCurrent()) return;

        await controller.addLineLayer(
          source,
          layer,
          const LineLayerProperties(
            lineColor: '#00BFFF',
            lineWidth: 4,
            lineOpacity: 0.9,
          ),
        );
        layerAdded = true;
        if (!isCurrent()) return;
        _visibleApproachSession = session;
        approachShown = true;
        _walkingApproach = approach;
        _scheduleNavigationCamera();
        return;
      }
    } catch (error) {
      debugPrint('Trail approach error: $error');
      if (approachShown) return;
    } finally {
      if (sourceAdded &&
          !approachShown &&
          mounted &&
          renderer == _renderer) {
        try {
          if (layerAdded) await controller.removeLayer(layer);
          await controller.removeSource(source);
        } catch (error) {
          debugPrint('Trail approach cleanup error: $error');
        }
      }
    }

    if (mounted && isCurrent()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Walking directions unavailable')),
      );
    }
  }

  void _scheduleNavigationCamera() {
    if (!_followCamera || _navigationCameraScheduled) return;
    _navigationCameraScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationCameraScheduled = false;
      if (mounted) _updateNavigationCamera();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  Future<void> _updateNavigationCamera() async {
    final controller = _controller;
    final position = _currentPosition;
    final progress = _trailProgress;
    final mapHeight = _mapKey.currentContext?.size?.height;
    if (!_followCamera ||
        !_isNavigating ||
        controller == null ||
        position == null ||
        progress == null ||
        mapHeight == null) {
      return;
    }

    final session = _navigationSession;
    final panelHeight = _navigationPanelKey.currentContext?.size?.height ?? 0;
    final bottom = math.min(panelHeight + 24, mapHeight * 0.55);
    final insets = EdgeInsets.only(
      top: (mapHeight - bottom) * 0.55,
      bottom: bottom,
    );

    final target = LatLng(position.latitude, position.longitude);
    final approachBearing = progress.offTrail ? _walkingBearing(target) : null;
    final bearing =
        approachBearing ??
        progress.forwardBearing ??
        controller.cameraPosition?.bearing ??
        0.0;
    try {
      if (_navigationInsets != insets) {
        _navigationInsets = insets;
        await controller.updateContentInsets(insets, false);
      }
      if (!mounted ||
          !_followCamera ||
          session != _navigationSession ||
          controller != _controller) {
        return;
      }
      await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            bearing: bearing % 360,
            zoom: 16,
            tilt: 35,
          ),
        ),
      );
    } catch (error) {
      debugPrint('Navigation camera update failed: $error');
    }
  }

  double? _walkingBearing(LatLng position) {
    final approach = _walkingApproach;
    if (approach == null) return null;

    var closestIndex = 0;
    var closestDistance = double.infinity;
    for (var i = 0; i < approach.length; i++) {
      final point = approach[i];
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        point.latitude,
        point.longitude,
      );
      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }

    for (final point in approach.skip(closestIndex)) {
      if (Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        point.latitude,
        point.longitude,
      ) < 20) continue;
      return Geolocator.bearingBetween(
        position.latitude,
        position.longitude,
        point.latitude,
        point.longitude,
      );
    }
    return null;
  }

  Future<void> _clearNavigationInsets() async {
    final controller = _controller;
    if (controller == null || _navigationInsets == EdgeInsets.zero) return;
    _navigationInsets = EdgeInsets.zero;
    try {
      await controller.updateContentInsets(EdgeInsets.zero, false);
    } catch (error) {
      debugPrint('Navigation camera reset failed: $error');
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
                  key: _mapKey,
                  styleString: _styleJson!,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(0, 0),
                    zoom: 1,
                  ),
                  onMapCreated: _onMapCreated,
                  onUserLocationUpdated: _onUserLocationUpdated,
                  onCameraMoveStarted: (reason) {
                    if (reason == CameraMoveReason.gesture) {
                      _centerOnFirstLocation = false;
                      if (_isNavigating && _followCamera) {
                        setState(() => _followCamera = false);
                      }
                    }
                  },
                  onCameraIdle: () {
                    if (!_followCamera) _clearNavigationInsets();
                  },
                  onStyleLoadedCallback: _onStyleLoaded,
                  onMapClick: _onMapClick,
                  onMapLongClick: _onMapClick,
                  myLocationEnabled:
                      _locationPermissionGranted || _isNavigating,
                  myLocationTrackingMode: MyLocationTrackingMode.none,
                  compassEnabled: true,
                  featureTapsTriggersMapClick: true,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                ),

                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 12,
                  child: SafeArea(
                    top: false,
                    child: _isNavigating ? _navigationPanel():
                      _selectedRoute != null ? _routePanel(_selectedRoute!) : const SizedBox.shrink()
                  ),
                ),
              ],
            ),
    );
  }
}
