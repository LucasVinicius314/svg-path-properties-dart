import 'package:svg_path_properties_dart/point.dart';
import 'package:svg_path_properties_dart/point_properties.dart';

abstract class Properties {
  double getTotalLength();
  Point getPointAtLength({required double pos});
  Point getTangentAtLength({required double pos});
  PointProperties getPropertiesAtLength({required double pos});
}
