import 'dart:math' as math;

import 'package:svg_path_properties_dart/bezier_values.dart';
import 'package:svg_path_properties_dart/point.dart';

Point cubicPoint({
  required List<double> xs,
  required List<double> ys,
  required double t,
}) {
  final x = (1 - t) * (1 - t) * (1 - t) * xs[0] +
      3 * (1 - t) * (1 - t) * t * xs[1] +
      3 * (1 - t) * t * t * xs[2] +
      t * t * t * xs[3];
  final y = (1 - t) * (1 - t) * (1 - t) * ys[0] +
      3 * (1 - t) * (1 - t) * t * ys[1] +
      3 * (1 - t) * t * t * ys[2] +
      t * t * t * ys[3];

  return Point(
    x: x,
    y: y,
  );
}

Point cubicDerivative({
  required List<double> xs,
  required List<double> ys,
  required double t,
}) {
  final derivative = quadraticPoint(
    xs: [3 * (xs[1] - xs[0]), 3 * (xs[2] - xs[1]), 3 * (xs[3] - xs[2])],
    ys: [3 * (ys[1] - ys[0]), 3 * (ys[2] - ys[1]), 3 * (ys[3] - ys[2])],
    t: t,
  );

  return derivative;
}

double getCubicArcLength({
  required List<double> xs,
  required List<double> ys,
  required double t,
}) {
  // TODO: fix
  /*if (xs.length >= tValues.length) {
        throw new Error('too high n bezier');
      }*/

  const n = 20;

  var z = t / 2;
  var sum = 0.0;

  for (var i = 0; i < n; i++) {
    var correctedT = z * tValues[n][i] + z;
    sum += cValues[n][i] * bFunc(xs: xs, ys: ys, t: correctedT);
  }

  return z * sum;
}

Point quadraticPoint({
  required List<double> xs,
  required List<double> ys,
  required double t,
}) {
  final x = (1 - t) * (1 - t) * xs[0] + 2 * (1 - t) * t * xs[1] + t * t * xs[2];
  final y = (1 - t) * (1 - t) * ys[0] + 2 * (1 - t) * t * ys[1] + t * t * ys[2];

  return Point(
    x: x,
    y: y,
  );
}

double getQuadraticArcLength({
  required List<double> xs,
  required List<double> ys,
  required double t,
}) {
  // TODO: fix
  // if (t === undefined) {
  //   t = 1;
  // }

  final ax = xs[0] - 2 * xs[1] + xs[2];
  final ay = ys[0] - 2 * ys[1] + ys[2];
  final bx = 2 * xs[1] - 2 * xs[0];
  final by = 2 * ys[1] - 2 * ys[0];

  final A = 4 * (ax * ax + ay * ay);
  final B = 4 * (ax * bx + ay * by);
  final C = bx * bx + by * by;

  if (A == 0) {
    return t *
        math.sqrt(math.pow(xs[2] - xs[0], 2) + math.pow(ys[2] - ys[0], 2));
  }

  final b = B / (2 * A);
  final c = C / A;
  final u = t + b;
  final k = c - b * b;

  final uuk = u * u + k > 0 ? math.sqrt(u * u + k) : 0;
  final bbk = b * b + k > 0 ? math.sqrt(b * b + k) : 0;
  final term = b + math.sqrt(b * b + k) != 0 && ((u + uuk) / (b + bbk)) != 0
      ? k * math.log(((u + uuk) / (b + bbk)).abs())
      : 0;

  return (math.sqrt(A) / 2) * (u * uuk - b * bbk + term);
}

Point quadraticDerivative({
  required List<double> xs,
  required List<double> ys,
  required double t,
}) {
  return Point(
    x: (1 - t) * 2 * (xs[1] - xs[0]) + t * 2 * (xs[2] - xs[1]),
    y: (1 - t) * 2 * (ys[1] - ys[0]) + t * 2 * (ys[2] - ys[1]),
  );
}

double bFunc({
  required List<double> xs,
  required List<double> ys,
  required double t,
}) {
  final xbase = getDerivative(derivative: 1, t: t, vs: xs);
  final ybase = getDerivative(derivative: 1, t: t, vs: ys);
  final combined = xbase * xbase + ybase * ybase;

  return math.sqrt(combined);
}

/// Compute the curve derivative (hodograph) at t.
double getDerivative({
  required double derivative,
  required double t,
  required List<double> vs,
}) {
  // the derivative of any 't'-less function is zero.
  final n = vs.length - 1;

  if (n == 0) {
    return 0;
  }

  // direct values? compute!
  if (derivative == 0) {
    var value = 0.0;

    for (var k = 0; k <= n; k++) {
      value += binomialCoefficients[n][k] *
          math.pow(1 - t, n - k) *
          math.pow(t, k) *
          vs[k];
    }

    return value;
  } else {
    // Still some derivative? go down one order, then try
    // for the lower order curve's.
    var newVs = List.filled(n, 0.0);

    for (var k = 0; k < n; k++) {
      newVs[k] = n * (vs[k + 1] - vs[k]);
    }

    return getDerivative(
      derivative: derivative - 1,
      t: t,
      vs: newVs,
    );
  }
}

double t2length({
  required double length,
  required double totalLength,
  required double Function(double t) func,
}) {
  var error = 1.0;
  var t = length / totalLength;
  var step = (length - func(t)) / totalLength;

  var numIterations = 0;

  while (error > 0.001) {
    final increasedTLength = func(t + step);
    final increasedTError = (length - increasedTLength).abs() / totalLength;

    if (increasedTError < error) {
      error = increasedTError;
      t += step;
    } else {
      final decreasedTLength = func(t - step);
      final decreasedTError = (length - decreasedTLength).abs() / totalLength;

      if (decreasedTError < error) {
        error = decreasedTError;
        t -= step;
      } else {
        step /= 2;
      }
    }

    numIterations++;

    if (numIterations > 500) {
      break;
    }
  }

  return t;
}
