
class TrailSymbol {
  final String raw;
  final String wayColor;
  final String background;
  final String foreground;
  final String foreground2;
  final String text;
  final String textColor;

  const TrailSymbol({
    required this.raw,
    required this.wayColor,
    required this.background,
    required this.foreground,
    required this.foreground2,
    required this.text,
    required this.textColor,
  });

  factory TrailSymbol.parse(String raw) {
    final parts = raw.split(':');

    String part(int index) =>
        index < parts.length ? parts[index].trim() : '';

    return TrailSymbol(
      raw: raw,
      wayColor: part(0),
      background: part(1),
      foreground: part(2),
      foreground2: part(3),
      text: part(4),
      textColor: part(5),
    );
  }

  String get shape {
    final value = foreground.toLowerCase();

    const shapes = [
      'stripe',
      'bar',
      'triangle',
      'cross',
      'dot',
      'diamond',
      'shell',
      'wheel',
      'hiker',
      'letter',
    ];

    for (final item in shapes) {
      if (value.contains(item)) return item;
    }

    return 'unknown';
  }

  String get markingColor {
    final value = foreground.toLowerCase();

    const colors = [
      'red',
      'blue',
      'yellow',
      'green',
      'black',
      'white',
      'orange',
      'purple',
    ];

    for (final color in colors) {
      if (value.startsWith(color)) return color;
    }

    return wayColor.isNotEmpty ? wayColor : 'unknown';
  }
}
