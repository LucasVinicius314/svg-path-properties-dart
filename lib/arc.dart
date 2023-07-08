import 'dart:math' as math;

import 'package:svg_path_properties_dart/point.dart';
import 'package:svg_path_properties_dart/point_properties.dart';
import 'package:svg_path_properties_dart/properties.dart';

class Arc extends Properties {
  Arc(
    {
required this.x0,
required this.y0,
required this.rx,
required this.ry,
required this.xAxisRotate,
required this.LargeArcFlag,
required this.SweepFlag,
required this.x1,
required this.y1,
    }
  ) {

    final lengthProperties = approximateArcLengthOfCurve(300, function(t: number) {
      return pointOnEllipticalArc(
        { x: x0, y: y0 },
        rx,
        ry,
        xAxisRotate,
        LargeArcFlag,
        SweepFlag,
        { x: x1, y: y1 },
        t
      );
    });
    
    length = lengthProperties.arcLength;
  }

  double x0;
  double y0;
  double rx;
  double ry;
  double xAxisRotate;
  bool LargeArcFlag;
  bool SweepFlag;
  double  x1;
  double  y1;
  double  length;

  // constructor(
  //   x0: number,
  //   y0: number,
  //   rx: number,
  //   ry: number,
  //   xAxisRotate: number,
  //   LargeArcFlag: boolean,
  //   SweepFlag: boolean,
  //   x1: number,
  //   y1: number
  // ) {
  //   this.x0 = x0;
  //   this.y0 = y0;
  //   this.rx = rx;
  //   this.ry = ry;
  //   this.xAxisRotate = xAxisRotate;
  //   this.LargeArcFlag = LargeArcFlag;
  //   this.SweepFlag = SweepFlag;
  //   this.x1 = x1;
  //   this.y1 = y1;

  //   const lengthProperties = approximateArcLengthOfCurve(300, function(t: number) {
  //     return pointOnEllipticalArc(
  //       { x: x0, y: y0 },
  //       rx,
  //       ry,
  //       xAxisRotate,
  //       LargeArcFlag,
  //       SweepFlag,
  //       { x: x1, y: y1 },
  //       t
  //     );
  //   });
  //   this.length = lengthProperties.arcLength;
  // }

  @override
  double getTotalLength (){
    return length;
  }

  @override
  Point getPointAtLength({required double pos}) {
    if (pos < 0) {
      pos = 0;
    } else if (pos > length) {
      pos = length;
    }

    final position = pointOnEllipticalArc(
      Point(x: x0, y: y0),
      rx,
      ry,
      xAxisRotate,
      LargeArcFlag,
      SweepFlag,
      Point(x: x1, y: y1),
      pos / length,
    );

    return Point(x: position.x, y: position.y,);
  }

  Point getTangentAtLength({required double pos}){
    if (pos < 0) {
      pos = 0;
    } else if (pos > length) {
      pos = length;
    }

    // TODO: fix
    final pointDist = 0.05; // needs testing
    final p1 = getPointAtLength(pos);

    Point p2;

    if (pos < 0) {
      pos = 0;
    } else if (pos > length) {
      pos = length;
    }

    if (pos < length - pointDist) {
      p2 = getPointAtLength(pos + pointDist);
    } else {
      p2 = getPointAtLength(pos - pointDist);
    }

    const xDist = p2.x - p1.x;
    const yDist = p2.y - p1.y;
    const dist = math.sqrt(xDist * xDist + yDist * yDist);

    if (pos < length - pointDist) {
      return Point(x: -xDist / dist, y: -yDist / dist);
    } else {
      return Point(x: xDist / dist, y: yDist / dist);
    }
  }

  @override
  PointProperties getPropertiesAtLength({required double pos}) {
    final tangent = getTangentAtLength(pos);
    final point = getPointAtLength(pos);

    return PointProperties(x: point.x, y: point.y, tangentX: tangent.x, tangentY: tangent.y,);
  }
}

class PointOnEllipticalArc {
  PointOnEllipticalArc({
    required this.x,
    required this.y,
    required this.ellipticalArcAngle,
  });

  double x;
  double y;
  double ellipticalArcAngle;
}

PointOnEllipticalArc pointOnEllipticalArc(
  p0: Point,
  rx: number,
  ry: number,
  xAxisRotation: number,
  largeArcFlag: boolean,
  sweepFlag: boolean,
  p1: Point,
  t: number
) {
  // In accordance to: http://www.w3.org/TR/SVG/implnote.html#ArcOutOfRangeParameters
  rx = rx.abs;
  ry = ry.abs;
  xAxisRotation = mod(xAxisRotation, 360);

  final xAxisRotationRadians = toRadians(xAxisRotation);

  // If the endpoints are identical, then this is equivalent to omitting the elliptical arc segment entirely.
  if (p0.x == p1.x && p0.y == p1.y) {
    return PointOnEllipticalArc(x: p0.x, y: p0.y, ellipticalArcAngle: 0,); // Check if angle is correct
  }

  // If rx = 0 or ry = 0 then this arc is treated as a straight line segment joining the endpoints.
  if (rx == 0 || ry == 0) {
    //return this.pointOnLine(p0, p1, t);
    return PointOnEllipticalArc(x: 0, y: 0, ellipticalArcAngle: 0,); // Check if angle is correct
  }

  // Following "Conversion from endpoint to center parameterization"
  // http://www.w3.org/TR/SVG/implnote.html#ArcConversionEndpointToCenter

  // Step #1: Compute transformedPoint
  final dx = (p0.x - p1.x) / 2;
  final dy = (p0.y - p1.y) / 2;
  final transformedPoint = Point(x: math.cos(xAxisRotationRadians) * dx + math.sin(xAxisRotationRadians) * dy,
    y: -math.sin(xAxisRotationRadians) * dx + math.cos(xAxisRotationRadians) * dy,);

  // Ensure radii are large enough
  final radiiCheck =
    math.pow(transformedPoint.x, 2) / math.pow(rx, 2) +
    math.pow(transformedPoint.y, 2) / math.pow(ry, 2);

  if (radiiCheck > 1) {
    rx = math.sqrt(radiiCheck) * rx;
    ry = math.sqrt(radiiCheck) * ry;
  }

  // Step #2: Compute transformedCenter
  final cSquareNumerator =
    math.pow(rx, 2) * math.pow(ry, 2) -
    math.pow(rx, 2) * math.pow(transformedPoint.y, 2) -
    math.pow(ry, 2) * math.pow(transformedPoint.x, 2);

  final cSquareRootDenom =
    math.pow(rx, 2) * math.pow(transformedPoint.y, 2) +
    math.pow(ry, 2) * math.pow(transformedPoint.x, 2);

  var cRadicand = cSquareNumerator / cSquareRootDenom;
  // Make sure this never drops below zero because of precision
  cRadicand = cRadicand < 0 ? 0 : cRadicand;

  final cCoef = (largeArcFlag != sweepFlag ? 1 : -1) * math.sqrt(cRadicand);
  final transformedCenter = Point(x: cCoef * ((rx * transformedPoint.y) / ry),
    y: cCoef * (-(ry * transformedPoint.x) / rx),);

  // Step #3: Compute center
  final center = Point(x:
      math.cos(xAxisRotationRadians) * transformedCenter.x -
      math.sin(xAxisRotationRadians) * transformedCenter.y +
      (p0.x + p1.x) / 2,
    y:
      math.sin(xAxisRotationRadians) * transformedCenter.x +
      math.cos(xAxisRotationRadians) * transformedCenter.y +
      (p0.y + p1.y) / 2,);

  // Step #4: Compute start/sweep angles
  // Start angle of the elliptical arc prior to the stretch and rotate operations.
  // Difference between the start and end angles
  final startVector = Point(x: (transformedPoint.x - transformedCenter.x) / rx,
    y: (transformedPoint.y - transformedCenter.y) / ry,);
  
  final startAngle = angleBetween(
    v0: Point(x: 1,
      y: 0),
    v1:  startVector,
  );

  final endVector = Point(x: (-transformedPoint.x - transformedCenter.x) / rx,
    y: (-transformedPoint.y - transformedCenter.y) / ry,);

  var sweepAngle = angleBetween(v0: startVector, v1: endVector);

  if (!sweepFlag && sweepAngle > 0) {
    sweepAngle -= 2 * math.pi;
  } else if (sweepFlag && sweepAngle < 0) {
    sweepAngle += 2 * math.pi;
  }
  // We use % instead of `mod(..)` because we want it to be -360deg to 360deg(but actually in radians)
  sweepAngle %= 2 * math.pi;

  // From http://www.w3.org/TR/SVG/implnote.html#ArcParameterizationAlternatives
  final angle = startAngle + sweepAngle * t;
  final ellipseComponentX = rx * math.cos(angle);
  final ellipseComponentY = ry * math.sin(angle);

  final point = Point(x:
      math.cos(xAxisRotationRadians) * ellipseComponentX -
      math.sin(xAxisRotationRadians) * ellipseComponentY +
      center.x,
    y:
      math.sin(xAxisRotationRadians) * ellipseComponentX +
      math.cos(xAxisRotationRadians) * ellipseComponentY +
      center.y,
      // TODO: fix
    // ellipticalArcStartAngle: startAngle,
    // ellipticalArcEndAngle: startAngle + sweepAngle,
    // ellipticalArcAngle: angle,
    // ellipticalArcCenter: center,
    // resultantRx: rx,
    // resultantRy: ry,
    );

  return point;
}

// TODO: fix
dynamic approximateArcLengthOfCurve(
  {required double resolution,
  required Point Function(double t) pointOnCurveFunc,}
) {
  // Resolution is the number of segments we use
  resolution = resolution != 0 ? resolution : 500;

  var resultantArcLength = 0.0;
  final arcLengthMap = [];
  final approximationLines = [];

  var prevPoint = pointOnCurveFunc(0);
  var nextPoint;

  for (var i = 0; i < resolution; i++) {
    final t = clamp(val: i * (1 / resolution), min: 0, max: 1);
    nextPoint = pointOnCurveFunc(t);
    resultantArcLength += distance(p0: prevPoint, p1: nextPoint);
    approximationLines.push([prevPoint, nextPoint]);

    arcLengthMap.push({
      t: t,
      arcLength: resultantArcLength
    });

    prevPoint = nextPoint;
  }
  // Last stretch to the endpoint
  nextPoint = pointOnCurveFunc(1);
  approximationLines.push([prevPoint, nextPoint]);
  resultantArcLength += distance(prevPoint, nextPoint);
  arcLengthMap.push({
    t: 1,
    arcLength: resultantArcLength
  });

  return {
    arcLength: resultantArcLength,
    arcLengthMap: arcLengthMap,
    approximationLines: approximationLines
  };
};

double mod({required double x, required double m}){
  return ((x % m) + m) % m;
}

double toRadians({required double angle}){
  return angle * (math.pi / 180);
}

double  distance ({required Point p0, required Point p1}) {
  return math.sqrt(math.pow(p1.x - p0.x, 2) + math.pow(p1.y - p0.y, 2));
}

double clamp ({required double val, required double min, required double max}) {
  return math.min(math.max(val, min), max);
}

double  angleBetween ({required Point v0, required Point v1}) {
  final p = v0.x * v1.x + v0.y * v1.y;
  final n = math.sqrt(
    (math.pow(v0.x, 2) + math.pow(v0.y, 2)) * (math.pow(v1.x, 2) + math.pow(v1.y, 2))
  );
  final sign = v0.x * v1.y - v0.y * v1.x < 0 ? -1 : 1;
  final angle = sign * math.acos(p / n);

  return angle;
}

