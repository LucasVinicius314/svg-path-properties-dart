import 'package:svg_path_properties_dart/point.dart';
import 'package:svg_path_properties_dart/point_properties.dart';

abstract class PartProperties {
  PartProperties({
    required this.start,
    required this.end,
    required this.length,
  });

  Point start;
  Point end;
  double length;

  Point getPointAtLength({required double pos});
  Point getTangentAtLength({required double pos});
  PointProperties getPropertiesAtLength({required double pos});
}
