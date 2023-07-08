import 'dart:math' as math;

import 'package:svg_path_properties_dart/point.dart';
import 'package:svg_path_properties_dart/point_properties.dart';
import 'package:svg_path_properties_dart/properties.dart';

class LinearPosition implements Properties {
  LinearPosition({
    required this.x0,
    required this.x1,
    required this.y0,
    required this.y1,
  });

  double x0;
  double x1;
  double y0;
  double y1;

  @override
  double getTotalLength() {
    return math.sqrt(math.pow(x0 - x1, 2) + math.pow(y0 - y1, 2));
  }

  @override
  Point getPointAtLength({required double pos}) {
    var fraction = pos / math.sqrt(math.pow(x0 - x1, 2) + math.pow(y0 - y1, 2));

    fraction = fraction.isNaN ? 1 : fraction;
    final newDeltaX = (x1 - x0) * fraction;
    final newDeltaY = (y1 - y0) * fraction;

    return Point(
      x: x0 + newDeltaX,
      y: y0 + newDeltaY,
    );
  }

  @override
  Point getTangentAtLength({required double pos}) {
    final module = math.sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0));

    return Point(
      x: (x1 - x0) / module,
      y: (y1 - y0) / module,
    );
  }

  @override
  PointProperties getPropertiesAtLength({required double pos}) {
    final point = getPointAtLength(pos: pos);
    final tangent = getTangentAtLength(pos: pos);

    return PointProperties(
      x: point.x,
      y: point.y,
      tangentX: tangent.x,
      tangentY: tangent.y,
    );
  }
}
