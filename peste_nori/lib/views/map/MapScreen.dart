
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/HikeHistoryService.dart';

import './models/HikingRoute.dart';
import './services/RouteDataService.dart';
import './services/GpsNavigationService.dart';
import './services/TrailEntryService.dart';
import './map/TrailShieldRenderer.dart';
import './TrailSearchDelegate.dart';
import './SavedOfflineMapsSheet.dart';
import 'package:peste_nori/globals.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.isVisible = true});

  final bool isVisible;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapLibreMapController? _controller;
  TrailShieldRenderer? _renderer;
  final _mapBearing = ValueNotifier<double>(0);

  String? _styleJson;
  String? _status;
  final _cityLayerIds = <String>{};
  bool _hikingView = false;
  Future<void> _hikingViewUpdate = Future<void>.value();

  bool _loadingRoutes = false;
  late final Future<List<HikingRoute>> _routes;
  bool _routesLoaded = false;
  bool _downloading = false;
  bool _pickingOfflineArea = false;
  static const _offlineMinZoom = 9.0;
  static const _offlineMaxZoom = 15.0;
  static const _offlineTileLimit = 3000;
  static const _offlineStyleUrl = 'https://tiles.openfreemap.org/styles/liberty';

  double _downloadProgress = 0;

  int _routeCount = 0;
  int _visibleRouteCount = 0;

  HikingRoute? _selectedRoute;
  ({String name, double distanceMeters})? _selectedLandmark;
  bool _selectingMapFeature = false;
  static const _landmarkLayerIds = [
    'hiking-focus-landmarks',
    'hiking-focus-summits',
    'hiking-focus-ridges',
    'major-attractions',
  ];

  final GpsNavigationService _gpsService = GpsNavigationService();
  final _hikeHistory = HikeHistoryService();
  DocumentReference<Map<String, dynamic>>? _activeHike;

  bool _isNavigating = false;
  bool _startingNavigation = false;
  bool _followCamera = true;
  final _mapKey = GlobalKey();
  final _navigationPanelKey = GlobalKey();
  EdgeInsets _navigationInsets = EdgeInsets.zero;
  List<LatLng>? _walkingApproach;
  bool _loadingWalkingApproach = false;
  bool _walkingApproachUnavailable = false;
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
  CameraPosition? _initialMapCamera;
  bool _initializingMapLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeMapLocation();
    _loadStyle();
    _routes = RouteDataService().loadRoutes();
    _routes.ignore();
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible && _initialMapCamera == null) {
      _initializeMapLocation();
    }
  }

  @override
  void dispose() {
    _gpsService.stop();
    _mapBearing.dispose();
    super.dispose();
  }

  Future<void> _initializeMapLocation() async {
    if (_initializingMapLocation) return;
    _initializingMapLocation = true;
    var waitingForMapTab = false;
    var locationGranted = false;
    Position? position;
    try {
      var permission = await Geolocator.checkPermission();
      if (!mounted) return;
      if (permission == LocationPermission.denied) {
        if (!widget.isVisible) {
          waitingForMapTab = true;
          return;
        }
        permission = await Geolocator.requestPermission();
      }
      if (!mounted) return;
      locationGranted = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
      if (!locationGranted) return;

      if (!kIsWeb) {
        try {
          position = await Geolocator.getLastKnownPosition();
        } catch (error) {
          debugPrint('Cached map location unavailable: $error');
        }
      }
      if (!mounted) return;
      if (position == null ||
          DateTime.now().difference(position.timestamp) >
              const Duration(minutes: 10) ||
          position.accuracy > 100) {
        position = null;
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
        _centerOnFirstLocation = false;
      }
    } catch (e) {
      debugPrint('Initial map location unavailable: $e');
    } finally {
      _initializingMapLocation = false;
      if (mounted && !waitingForMapTab) {
        final fix = position;
        setState(() {
          _locationPermissionGranted = locationGranted;
          _initialMapCamera = fix == null
              ? const CameraPosition(target: LatLng(0, 0), zoom: 1)
              : CameraPosition(
                  target: LatLng(fix.latitude, fix.longitude),
                  zoom: 14,
                  tilt: 35,
                );
        });
      }
    }
  }

  Future<void> _loadStyle() async {
    try {
      final text = await rootBundle.loadString(
        'assets/mapStyle.json',
      );

      final style = jsonDecode(text) as Map<String, dynamic>;
      for (final layer in style['layers'] as List) {
        final id = layer['id'] as String;
        final sourceLayer = layer['source-layer'];
        final hiddenByDefault = layer['layout']?['visibility'] == 'none';
        if (!hiddenByDefault &&
            !id.startsWith('hiking-focus-') &&
            !id.contains('path_pedestrian') &&
            id != 'highway-name-path' &&
            const {
              'place',
              'poi',
              'building',
              'landuse',
              'transportation',
              'transportation_name',
              'aeroway',
              'aerodrome_label',
            }.contains(sourceLayer)) {
          _cityLayerIds.add(id);
        }
      }

      if (!mounted) return;

      setState(() {
        _styleJson = text;
        _status = translations.mapStyleLoaded;
      });
    } catch (e) {
      debugPrint('Map style loading failed: $e');
      if (!mounted) return;

      setState(() {
        _status = translations.mapStyleError;
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

    if (_hikingView) _applyHikingView();
    await _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    final renderer = _renderer;

    if (renderer == null || _loadingRoutes) return;

    _loadingRoutes = true;

    if (mounted) {
      setState(() {
        _status = translations.loadingHikingTrails;
      });
    }

    try {
      final routes = await _routes;
      if (!mounted || renderer != _renderer) return;

      final rendered = await renderer.displayRoutes(routes);

      if (!mounted || renderer != _renderer) return;
      final selectedRoute = _selectedRoute;
      if (selectedRoute != null) {
        await renderer.selectRoute(selectedRoute);
        if (!mounted || renderer != _renderer) return;
        if (_selectedRoute != selectedRoute) await renderer.clearSelection();
      }
      if (!mounted || renderer != _renderer) return;

      setState(() {
        _routeCount = routes.length;
        _visibleRouteCount = rendered;
        _routesLoaded = true;
        _status = translations.tapTrailSymbol;
      });
    } catch (e, stack) {
      debugPrint('ROUTE ERROR: $e');
      debugPrintStack(stackTrace: stack);

      if (!mounted) return;

      setState(() {
        _status = translations.routeLoadingFailed;
      });
    } finally {
      _loadingRoutes = false;
    }
  }

  Future<void> _onMapClick(
    math.Point<double> point,
    LatLng coordinates,
  ) async {
    final controller = _controller;
    final renderer = _renderer;
    if (controller == null ||
        renderer == null ||
        _selectingMapFeature ||
        _pickingOfflineArea ||
        _startingNavigation) {
      return;
    }

    final session = _navigationSession;
    _selectingMapFeature = true;
    try {
      HikingRoute? route;
      ({String name, double distanceMeters})? landmark;
      final shieldLayers = renderer.interactiveLayers;
      if (_routesLoaded && shieldLayers.isNotEmpty) {
        final shields = await controller.queryRenderedFeatures(
          point,
          shieldLayers,
          null,
        );
        for (final feature in shields.whereType<Map>()) {
          final properties = feature['properties'];
          final id = properties is Map ? properties['route_id']?.toString() : null;
          if (id == null) continue;
          route = renderer.routeForId(id);
          if (route != null) break;
        }
      }

      if (route == null) {
        final features = await controller.queryRenderedFeaturesInRect(
          Rect.fromCenter(center: Offset(point.x, point.y), width: 20, height: 20),
          _landmarkLayerIds,
          null,
        );
        if (!mounted || renderer != _renderer) return;
        for (final feature in features.whereType<Map>()) {
          final properties = feature['properties'];
          if (properties is! Map) continue;
          final name = properties['name']?.toString().trim();
          if (name == null || name.isEmpty) continue;

          if (!_routesLoaded) {
            _showMapMessage(translations.trailsStillLoading);
            return;
          }

          final geometry = feature['geometry'];
          final position = geometry is Map && geometry['type'] == 'Point'
              ? geometry['coordinates']
              : null;
          final target = position is List &&
                  position.length >= 2 &&
                  position[0] is num &&
                  position[1] is num
              ? LatLng(
                  (position[1] as num).toDouble(),
                  (position[0] as num).toDouble(),
                )
              : coordinates;
          final nearby = TrailEntryService.trailNearLandmark(
            renderer.routesById.values,
            target,
          );
          if (nearby == null) {
            _showMapMessage(translations.noTrailNear(name));
            return;
          }
          route = nearby.route;
          landmark = (name: name, distanceMeters: nearby.distanceMeters);
          break;
        }
      }

      final selectedRoute = route;
      if (selectedRoute == null ||
          !mounted ||
          renderer != _renderer ||
          session != _navigationSession) {
        return;
      }

      if (_isNavigating) {
        if (selectedRoute != _selectedRoute || landmark != null) {
          await _showTrailPreview(selectedRoute, landmark?.name);
        }
        return;
      }

      await _selectTrail(renderer, selectedRoute, landmark: landmark);
    } catch (error, stackTrace) {
      debugPrint('Map tap error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _selectingMapFeature = false;
    }
  }

  Future<void> _selectTrail(
    TrailShieldRenderer renderer,
    HikingRoute route, {
    ({String name, double distanceMeters})? landmark,
  }) async {
    await renderer.selectRoute(route);
    if (!mounted || renderer != _renderer) return;
    setState(() {
      _selectedRoute = route;
      _selectedLandmark = landmark;
      _status = translations.selectedTrail(route.displayName(translations.unnamedTrail));
    });
  }

  Future<void> _searchTrails() async {
    final renderer = _renderer;
    if (renderer == null || !_routesLoaded || _selectingMapFeature) return;

    _selectingMapFeature = true;
    try {
      final route = await showSearch<HikingRoute>(
        context: context,
        delegate: TrailSearchDelegate(renderer.routesById.values),
      );
      if (!mounted || route == null || renderer != _renderer) return;

      if (_isNavigating) {
        await _showTrailPreview(route, null);
      } else {
        await _selectTrail(renderer, route);
        if (mounted && _selectedRoute == route) await _zoomToSelectedRoute();
      }
    } catch (error) {
      debugPrint('Trail search selection failed: $error');
      if (mounted) _showMapMessage(translations.selectedTrailError);
    } finally {
      _selectingMapFeature = false;
    }
  }

  Future<void> _showTrailPreview(HikingRoute route, String? landmark) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.displayName(translations.unnamedTrail),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (landmark != null) Text(translations.nearLandmark(landmark)),
                if (route.to != null) Text(translations.trailDestination(route.to!)),
                if (route.distanceKm != null)
                  Text(translations.trailLength(route.distanceKm.toString())),
                if (route.symbol != null) Text(translations.trailMarking(route.symbol!)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMapMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _clearSelection() async {
    if (_selectedRoute == null) return;
    setState(() {
      _selectedRoute = null;
      _selectedLandmark = null;
    });
    await _stopNavigation();

    if (!mounted || _selectedRoute != null) return;
    await _renderer?.clearSelection();

    if (!mounted || _selectedRoute != null) return;
    setState(() => _status = translations.tapTrailSymbol);
  }

  Widget _routePanel(HikingRoute route) {
    final landmark = _selectedLandmark;
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
                    route.displayName(translations.unnamedTrail),
                    style: Theme.of(context)
                        .textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: _startingNavigation ? null : _clearSelection,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            if (landmark != null)
              Text(
                translations.landmarkDistanceFromTrail(landmark.name, landmark.distanceMeters.round().toString()),
              ),

            if (route.symbol != null)
              Text(translations.trailMarking(route.symbol!)),

            if (route.from != null)
              Text(translations.trailStart(route.from!)),

            if (route.to != null)
              Text(translations.trailDestination(route.to!)),

            if (route.distanceKm != null)
              Text(
                translations.trailDistanceOsm(route.distanceKm.toString()),
              ),

            if (route.network != null)
              Text(translations.trailNetwork(route.network!)),

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
                        ? translations.startingGps
                        : _isNavigating
                            ? translations.stopNavigation
                            : translations.followTrail,
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

  Future<void> _openOfflineMaps() async {
    if (kIsWeb) {
      _showMapMessage(translations.offlineAvailability);
      return;
    }

    final choice = await showModalBottomSheet<OfflineMapChoice>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const SavedOfflineMapsSheet(),
    );
    if (!mounted || choice == null) return;
    if (choice.downloadNew) {
      await _pickOfflineArea();
      return;
    }

    final region = choice.region;
    final controller = _controller;
    if (region == null || controller == null) return;
    setState(() {
      _followCamera = false;
      _centerOnFirstLocation = false;
    });
    await _clearNavigationInsets();
    if (!mounted || controller != _controller) return;
    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          region.definition.bounds,
          left: 24,
          top: 24,
          right: 24,
          bottom: 48,
        ),
      );
    } catch (error) {
      debugPrint('Could not show offline map: $error');
      if (mounted) _showMapMessage(translations.savedAreaOpenError);
    }
  }

  Future<void> _pickOfflineArea() async {
    final controller = _controller;
    if (controller == null || _downloading || _pickingOfflineArea) return;
    setState(() {
      _pickingOfflineArea = true;
      _followCamera = false;
      _centerOnFirstLocation = false;
    });

    try {
      await _clearNavigationInsets();
      if (!mounted || !_pickingOfflineArea || controller != _controller) return;
      await controller.moveCamera(CameraUpdate.bearingTo(0));
      if (!mounted || !_pickingOfflineArea || controller != _controller) return;
      await controller.moveCamera(CameraUpdate.tiltTo(0));
    } catch (error) {
      debugPrint('Could not reset the offline area camera: $error');
    }
  }

  int _estimatedOfflineTiles(LatLngBounds bounds) {
    int tileX(double longitude, int gridSize) =>
        ((longitude + 180) / 360 * gridSize).floor().clamp(0, gridSize - 1);

    int tileY(double latitude, int gridSize) {
      final radians = latitude.clamp(-85.05112878, 85.05112878) * math.pi / 180;
      final mercator = math.log(math.tan(math.pi / 4 + radians / 2));
      return ((1 - mercator / math.pi) / 2 * gridSize)
          .floor()
          .clamp(0, gridSize - 1);
    }

    var count = 0;
    for (var zoom = _offlineMinZoom.toInt(); zoom <= _offlineMaxZoom; zoom++) {
      final gridSize = 1 << zoom;
      final west = tileX(bounds.southwest.longitude, gridSize);
      final east = tileX(bounds.northeast.longitude, gridSize);
      final north = tileY(bounds.northeast.latitude, gridSize);
      final south = tileY(bounds.southwest.latitude, gridSize);
      final width = east >= west ? east - west + 1 : gridSize - west + east + 1;
      count += width * (south - north + 1);
    }
    return count;
  }

  Future<void> _downloadRegion() async {
    final controller = _controller;
    if (controller == null || _downloading || !_pickingOfflineArea) return;
    setState(() {
      _downloading = true;
      _downloadProgress = 0;
    });

    try {
      final bounds = await controller.getVisibleRegion();
      if (!mounted) return;
      if (_estimatedOfflineTiles(bounds) > _offlineTileLimit) {
        _finishOfflineDownload(translations.smallerOfflineArea);
        return;
      }

      final name = await showOfflineMapTitleDialog(
        context,
        initialTitle: _selectedRoute?.displayName(translations.unnamedTrail) ?? '',
      );
      if (!mounted) return;
      if (name == null) {
        setState(() => _downloading = false);
        return;
      }
      setState(() => _pickingOfflineArea = false);
      await setHttpHeaders({'User-Agent': 'PesteNori/1.0'});
      await setOfflineMaxConcurrentRequests(
        maxRequests: 4,
        maxRequestsPerHost: 4,
      );
      await setOfflineTileCountLimit(_offlineTileLimit);

      await downloadOfflineRegion(
        OfflineRegionDefinition(
          bounds: bounds,
          minZoom: _offlineMinZoom,
          maxZoom: _offlineMaxZoom,
          mapStyleUrl: _offlineStyleUrl,
        ),
        metadata: {'name': name},
        onEvent: (status) {
          if (!mounted || !_downloading) return;

          if (status is InProgress) {
            final total = status.requiredResourceCount;
            setState(() {
              _downloadProgress = total > 0
                  ? (status.completedResourceCount / total).clamp(0.0, 1.0)
                  : 0;
            });
          } else if (status is Success) {
            _finishOfflineDownload(translations.mapAreaDownloaded);
          } else if (status is Error) {
            _finishOfflineDownload(
              status.cause.code == 'TILE_COUNT_LIMIT_EXCEEDED'
                  ? translations.smallerOfflineArea
                  : translations.offlineDownloadError,
            );
            debugPrint('Offline download failed: ${status.cause}');
          }
        },
      );
    } catch (error) {
      if (!mounted || !_downloading) return;
      debugPrint('Offline download failed: $error');
      _finishOfflineDownload(
        translations.offlineDownloadError,
      );
    }
  }

  void _finishOfflineDownload(String message) {
    if (!mounted) return;
    setState(() => _downloading = false);
    if (widget.isVisible) _showMapMessage(message);
  }

  Widget _offlineAreaPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translations.chooseOfflineArea,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(translations.frameOfflineArea),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _downloading
                      ? null
                      : () => setState(() => _pickingOfflineArea = false),
                  child: Text(translations.cancel),
                ),
                FilledButton.icon(
                  onPressed: _downloading ? null : _downloadRegion,
                  icon: const Icon(Icons.download),
                  label: Text(translations.downloadArea),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startNavigation() async {
    final route = _selectedRoute;

    if (route == null || _startingNavigation || _selectingMapFeature) return;

    _followCamera = true;
    _navigationExpanded = false;
    _walkingApproach = null;
    final session = ++_navigationSession;

    setState(() {
      _startingNavigation = true;
      _status = translations.startingGpsTracking;
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
                ? translations.offTrailWarning
                : translations.followingTrail(route.displayName(translations.unnamedTrail));
          });

          if (progress.offTrail) {
            _setHikingView(false);
          } else if (progress.gpsAccuracyMeters <= 25 &&
              progress.distanceFromTrailMeters <= 25) {
            _walkingApproachUnavailable = false;
            _setHikingView(true);
          }
          if (!_hikingView &&
              progress.gpsAccuracyMeters <= 50 &&
              progress.distanceFromTrailMeters >
                  math.max(25, progress.gpsAccuracyMeters) &&
              !_walkingApproachUnavailable) {
            _requestWalkingApproach();
          }
          _scheduleNavigationCamera();
        },
        onError: (error) {
          if (!mounted || session != _navigationSession) return;

          setState(() {
            _status = translations.gpsError;
          });
        },
      );

      if (!mounted || session != _navigationSession) {
        await _gpsService.stop();
        return;
      }

      _saveHikeStart(route, DateTime.now());
      setState(() {
        _isNavigating = true;
      });
    } catch (e) {
      if (!mounted || session != _navigationSession) return;

      setState(() {
        _status = switch (e) {
          GpsNavigationStartError.servicesDisabled => translations.locationServicesRequired,
          GpsNavigationStartError.permissionRequired => translations.locationPermissionRequired,
          GpsNavigationStartError.invalidTrail => translations.invalidTrailGeometry,
          _ => translations.navigationStartError,
        };
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

  Future<void> _saveHikeStart(HikingRoute route, DateTime startedAt) async {
    final record = _hikeHistory.newHike();
    _activeHike = record;
    try {
      await _hikeHistory.start(record, route, startedAt);
    } catch (error) {
      debugPrint('Could not record hike start: $error');
      if (mounted && widget.isVisible) {
        _showMapMessage(translations.hikeSaveError);
      }
    }
  }

  Future<void> _saveHikeEnd(
    DocumentReference<Map<String, dynamic>> record,
    DateTime endedAt,
  ) async {
    try {
      await _hikeHistory.finish(record, endedAt);
    } catch (error) {
      debugPrint('Could not record hike end: $error');
      if (mounted && widget.isVisible) {
        _showMapMessage(translations.hikeEndSaveError);
      }
    }
  }

  Future<void> _stopNavigation() async {
    _navigationSession++;
    final hike = _activeHike;
    _activeHike = null;
    if (hike != null) _saveHikeEnd(hike, DateTime.now());
    final restoreMap = _setHikingView(false);
    _followCamera = false;
    _walkingApproach = null;
    _loadingWalkingApproach = false;
    _walkingApproachUnavailable = false;
    final approachSession = _visibleApproachSession;
    _visibleApproachSession = null;
    await _gpsService.stop();
    await restoreMap;

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
      _status = translations.navigationStopped;
    });
  }

  Future<void> _setHikingView(bool enabled) {
    if (_hikingView == enabled) return _hikingViewUpdate;
    _hikingView = enabled;
    return _applyHikingView();
  }

  Future<void> _applyHikingView() {
    final controller = _controller;
    final renderer = _renderer;
    final hikingView = _hikingView;
    if (controller == null || renderer == null) return _hikingViewUpdate;

    _hikingViewUpdate = _hikingViewUpdate.then((_) async {
      if (!mounted || renderer != _renderer || hikingView != _hikingView) {
        return;
      }
      try {
        final approach = _visibleApproachSession;
        await Future.wait([
          for (final layer in _cityLayerIds)
            controller.setLayerVisibility(layer, !hikingView),
          if (approach != null)
            controller.setLayerVisibility(
              '$_entryLayerId-$approach',
              !hikingView,
            ),
        ]);
      } catch (error) {
        debugPrint('Hiking map layer update failed: $error');
      }
    });
    return _hikingViewUpdate;
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

                  Expanded(
                    child: Text(
                      translations.trailNavigation,
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

          if (!_hikingView && _loadingWalkingApproach)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(translations.findingWalkingDirections),
            )
          else if (!_hikingView && _walkingApproachUnavailable)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: Text(translations.walkingDirectionsUnavailable)),
                TextButton(
                  onPressed: _requestWalkingApproach,
                  child: Text(translations.retry),
                ),
              ],
            )
          else if (_walkingApproach == null &&
              progress != null &&
              progress.distanceFromTrailMeters > 25 &&
              progress.gpsAccuracyMeters > 50)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(translations.waitingForAccurateGps),
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
                    Text(
                      translations.waitingForGps,
                      style: const TextStyle(fontSize: 12),
                    )
                  else ...[
                    Text(
                      translations.distanceFromTrail(progress.distanceFromTrailMeters.toStringAsFixed(0)),
                      style: const TextStyle(fontSize: 12),
                    ),

                    Text(
                      translations.gpsAccuracy(progress.gpsAccuracyMeters.toStringAsFixed(0)),
                      style: const TextStyle(fontSize: 12),
                    ),

                    if (progress.remainingMeters != null)
                      Text(
                        translations.estimatedRemaining((progress.remainingMeters! / 1000).toStringAsFixed(2)),
                        style: const TextStyle(fontSize: 12),
                      ),

                    if (progress.offTrail)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          translations.offTrailWarning,
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
                        tooltip: translations.followGps,
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
                        tooltip: translations.showTrail,
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
                        tooltip: translations.myLocation,
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
                        tooltip: translations.stopNavigation,
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


  Future<void> _requestWalkingApproach() async {
    final position = _currentPosition;
    final route = _selectedRoute;
    if (_loadingWalkingApproach ||
        _walkingApproach != null ||
        _hikingView ||
        !_isNavigating ||
        position == null ||
        route == null) {
      return;
    }

    final session = _navigationSession;
    setState(() {
      _loadingWalkingApproach = true;
      _walkingApproachUnavailable = false;
    });
    _scheduleNavigationCamera();

    final shown = await _showConnectionToTrail(
      LatLng(position.latitude, position.longitude),
      route,
      session,
    );
    if (!mounted || session != _navigationSession) return;
    setState(() {
      _loadingWalkingApproach = false;
      _walkingApproachUnavailable = !shown && !_hikingView;
    });
    _scheduleNavigationCamera();
  }

  Future<bool> _showConnectionToTrail(
    LatLng userLocation,
    HikingRoute route,
    int session,
  ) async {
    final controller = _controller;
    if (controller == null) return false;
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
      if (!isCurrent() || _hikingView) return false;
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
        if (!isCurrent() || _hikingView) return false;

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
        if (!isCurrent() || _hikingView) return false;
        _visibleApproachSession = session;
        approachShown = true;
        _walkingApproach = approach;
        return true;
      }
    } catch (error) {
      debugPrint('Trail approach error: $error');
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

    return false;
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
    final approachBearing = _hikingView ? null : _walkingBearing(target);
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

  Future<void> _resetMapNorth() async {
    final controller = _controller;
    if (controller == null) return;
    if (_isNavigating && _followCamera) {
      setState(() => _followCamera = false);
    }
    await _clearNavigationInsets();
    if (!mounted || controller != _controller) return;
    try {
      await controller.animateCamera(CameraUpdate.bearingTo(0));
    } catch (error) {
      debugPrint('Map compass reset failed: $error');
    }
  }

  Widget _mapCompass() {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      elevation: 3,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: translations.resetMapNorth,
        onPressed: _resetMapNorth,
        icon: ValueListenableBuilder<double>(
          valueListenable: _mapBearing,
          builder: (context, bearing, _) {
            return Transform.rotate(
              angle: -bearing * math.pi / 180,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'N',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const Icon(Icons.navigation, color: Colors.redAccent, size: 18),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translations.hikingMapTitle),
        actions: [
          IconButton(
            tooltip: translations.searchTrails,
            onPressed: _routesLoaded && !_startingNavigation && !_pickingOfflineArea
                ? _searchTrails
                : null,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: translations.savedOfflineMaps,
            onPressed: _controller == null || _downloading || _pickingOfflineArea
                ? null
                : _openOfflineMaps,
            icon: const Icon(Icons.download),
          ),
        ],
        bottom: _downloading && !_pickingOfflineArea
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: _downloadProgress > 0 ? _downloadProgress : null,
                  semanticsLabel: translations.downloadingOfflineMap,
                ),
              )
            : null,
      ),
      body: _styleJson == null || _initialMapCamera == null
          ? Center(
              child: Text(
                _styleJson == null ? _status ?? translations.loadingMap : translations.findingLocation,
              ),
            )
          : Stack(
              children: [
                MapLibreMap(
                  key: _mapKey,
                  styleString: _styleJson!,
                  initialCameraPosition: _initialMapCamera!,
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
                  onCameraMove: (camera) {
                    if (mounted) _mapBearing.value = camera.bearing;
                  },
                  trackCameraPosition: true,
                  onStyleLoadedCallback: _onStyleLoaded,
                  onMapClick: _onMapClick,
                  onMapLongClick: _onMapClick,
                  myLocationEnabled:
                      _locationPermissionGranted || _isNavigating,
                  myLocationTrackingMode: MyLocationTrackingMode.none,
                  compassEnabled: false,
                  featureTapsTriggersMapClick: true,
                  rotateGesturesEnabled: !_pickingOfflineArea,
                  tiltGesturesEnabled: !_pickingOfflineArea,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                ),

                if (_pickingOfflineArea)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: SafeArea(bottom: false, child: _mapCompass()),
                ),

                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 12,
                  child: SafeArea(
                    top: false,
                    child: _pickingOfflineArea
                        ? _offlineAreaPanel()
                        : _isNavigating
                        ? _navigationPanel()
                        : _selectedRoute != null
                        ? _routePanel(_selectedRoute!)
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
    );
  }
}
