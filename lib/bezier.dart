import 'dart:math' as math;

import 'package:svg_path_properties_dart/bezier_functions.dart';
import 'package:svg_path_properties_dart/point.dart';
import 'package:svg_path_properties_dart/point_properties.dart';
import 'package:svg_path_properties_dart/properties.dart';

class Bezier extends Properties {
  Bezier({
    required double ax,
    required double ay,
    required double bx,
    required double by,
    required double cx,
    required double cy,
    required double? dx,
    required double? dy,
  }) {
    a = Point(x: ax, y: ay);
    b = Point(x: bx, y: by);
    c = Point(x: cx, y: cy);

    if (dx != null && dy != null) {
      getArcLength = getCubicArcLength;
      getPoint = cubicPoint;
      getDerivative = cubicDerivative;
      d = Point(x: dx, y: dy);
    } else {
      getArcLength = getQuadraticArcLength;
      getPoint = quadraticPoint;
      getDerivative = quadraticDerivative;
      d = Point(x: 0, y: 0);
    }

    length = getArcLength(
      xs: [a.x, b.x, c.x, d.x],
      ys: [a.y, b.y, c.y, d.y],
      t: 1,
    );
  }

  late Point a;
  late Point b;
  late Point c;
  late Point d;
  late double length;
  late double Function({
    required List<double> xs,
    required List<double> ys,
    required double t,
  }) getArcLength;
  late Point Function({
    required List<double> xs,
    required List<double> ys,
    required double t,
  }) getPoint;
  late Point Function({
    required List<double> xs,
    required List<double> ys,
    required double t,
  }) getDerivative;

  @override
  double getTotalLength() {
    return length;
  }

  @override
  Point getPointAtLength({required double pos}) {
    final xs = [a.x, b.x, c.x, d.x];
    final xy = [a.y, b.y, c.y, d.y];
    final t = t2length(
      length: pos,
      totalLength: pos,
      func: (i) => getArcLength(xs: xs, ys: xy, t: i),
    );

    return getPoint(
      xs: xs,
      ys: xy,
      t: t,
    );
  }

  @override
  Point getTangentAtLength({required double pos}) {
    final xs = [a.x, b.x, c.x, d.x];
    final xy = [a.y, b.y, c.y, d.y];
    final t = t2length(
      length: pos,
      totalLength: length,
      func: (i) => getArcLength(xs: xs, ys: xy, t: i),
    );

    final derivative = getDerivative(xs: xs, ys: xy, t: t);
    final mdl =
        math.sqrt(derivative.x * derivative.x + derivative.y * derivative.y);

    Point tangent;
    if (mdl > 0) {
      tangent = Point(x: derivative.x / mdl, y: derivative.y / mdl);
    } else {
      tangent = Point(x: 0, y: 0);
    }

    return tangent;
  }

  @override
  PointProperties getPropertiesAtLength({required double pos}) {
    final xs = [a.x, b.x, c.x, d.x];
    final xy = [a.y, b.y, c.y, d.y];
    final t = t2length(
      length: pos,
      totalLength: length,
      func: (i) => getArcLength(xs: xs, ys: xy, t: i),
    );

    final derivative = getDerivative(xs: xs, ys: xy, t: t);
    final mdl =
        math.sqrt(derivative.x * derivative.x + derivative.y * derivative.y);

    Point tangent;
    if (mdl > 0) {
      tangent = Point(x: derivative.x / mdl, y: derivative.y / mdl);
    } else {
      tangent = Point(x: 0, y: 0);
    }

    final point = getPoint(xs: xs, ys: xy, t: t);

    return PointProperties(
      x: point.x,
      y: point.y,
      tangentX: tangent.x,
      tangentY: tangent.y,
    );
  }

  Point getC() {
    return c;
  }

  Point getD() {
    return d;
  }
}
