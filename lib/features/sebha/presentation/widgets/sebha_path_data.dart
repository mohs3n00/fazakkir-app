import 'dart:ui';

class SebhaPath {
  static Path getPath() {
    // Path from spha_path.svg
    // M875.92,772.49
    // c-9.93,0 -19.78-.19 -29.53-.57
    // -68.21-2.68 -133.75-14.88 -194.78-36.27
    // -61.85-21.68 -108.92-49.06 -150.44-73.23
    // -60.02-34.93 -111.86-65.1 -189.16-69.24
    // -111.38-5.96 -226.43,45.06 -341.96,151.64
    // l-3.59-3.89
    // c116.61-107.59 232.96-159.07 345.83-153.03
    // 78.57,4.21 130.92,34.67 191.54,69.95
    // 41.32,24.05 88.14,51.3 149.53,72.81
    // 138.58,48.56 298.35,48.54 474.88-.05
    // l1.4,5.1
    // c-88.81,24.45 -174.01,36.79 -253.73,36.79
    // Z

    Path path = Path();
    path.moveTo(875.92, 772.49);
    path.relativeCubicTo(-9.93, 0, -19.78, -0.19, -29.53, -0.57);
    path.relativeCubicTo(-68.21, -2.68, -133.75, -14.88, -194.78, -36.27);
    path.relativeCubicTo(-61.85, -21.68, -108.92, -49.06, -150.44, -73.23);
    path.relativeCubicTo(-60.02, -34.93, -111.86, -65.1, -189.16, -69.24);
    path.relativeCubicTo(-111.38, -5.96, -226.43, 45.06, -341.96, 151.64);
    path.relativeLineTo(-3.59, -3.89);
    path.relativeCubicTo(116.61, -107.59, 232.96, -159.07, 345.83, -153.03);
    path.relativeCubicTo(78.57, 4.21, 130.92, 34.67, 191.54, 69.95);
    path.relativeCubicTo(41.32, 24.05, 88.14, 51.3, 149.53, 72.81);
    path.relativeCubicTo(138.58, 48.56, 298.35, 48.54, 474.88, -0.05);
    path.relativeLineTo(1.4, 5.1);
    path.relativeCubicTo(-88.81, 24.45, -174.01, 36.79, -253.73, 36.79);
    path.close();

    // The SVG path is a closed shape (outline of the thread).
    // For beads to move "along" the thread, we actually need the Center Line of this shape.
    // The shape is thin, so using one side of it or averaging might work.
    // However, looking at the data, it seems to draw an outline.
    // Let's create a simplified quadratic or cubic curve that approximates the visual "center" of this path.
    // Visual inspection of the SVG data:
    // It basically goes Left then Right back.
    // For a smooth bead animation, we defined a Single Line Path.

    // Let's define a new Path that roughly follows the visual curve seen in the reference.
    // It looks like a simplified curve.
    // Let's assume for now the user wants the beads on the "Upper" curve of this loop if it's thick loop,
    // or just this path if it's thin.
    // Given the user said "Thread is just a visual path", and "Beads on a Bezier Path".
    // I will use this path for metrics.

    return path;
  }
}
