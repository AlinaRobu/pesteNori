
class HikingRoute {
  final String id;
  final String name;
  final String routeType;
  final String? symbol;
  final String? network;
  final String? from;
  final String? to;
  final String? ref;
  final String? description;
  final double? distanceKm;
  final String? complete;
  final Map<String, dynamic> geometry;
  final Map<String, dynamic> tags;

  const HikingRoute({
    required this.id,
    required this.name,
    required this.routeType,
    required this.geometry,
    required this.tags,
    this.symbol,
    this.network,
    this.from,
    this.to,
    this.ref,
    this.description,
    this.distanceKm,
    this.complete,
  });

  factory HikingRoute.fromFeature(Map<String, dynamic> feature) {
    final properties =
        Map<String, dynamic>.from(feature['properties'] ?? {});

    final rawDistance = properties['distance']?.toString();

    return HikingRoute(
      id: properties['@id']?.toString() ?? '',
      name: properties['name']?.toString() ?? 'Unnamed trail',
      routeType: properties['route']?.toString() ?? '',
      symbol: properties['osmc:symbol']?.toString(),
      network: properties['network']?.toString(),
      from: properties['from']?.toString(),
      to: properties['to']?.toString(),
      ref: properties['ref']?.toString(),
      description: properties['description']?.toString(),
      distanceKm: double.tryParse(rawDistance ?? ''),
      complete: properties['complete']?.toString(),
      geometry: Map<String, dynamic>.from(feature['geometry'] ?? {}),
      tags: properties,
    );
  }

  bool get hasSymbol =>
      symbol != null && symbol!.trim().isNotEmpty;

  bool get hasGeometry =>
      geometry['type'] == 'LineString' ||
      geometry['type'] == 'MultiLineString';

  String get destination =>
      to?.trim().isNotEmpty == true ? to! : name;
}
