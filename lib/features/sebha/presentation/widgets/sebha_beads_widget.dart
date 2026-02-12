import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../logic/sebha_provider.dart';
import 'sebha_path_data.dart';

class SebhaBeadsWidget extends ConsumerStatefulWidget {
  const SebhaBeadsWidget({super.key});

  @override
  ConsumerState<SebhaBeadsWidget> createState() => _SebhaBeadsWidgetState();
}

class _SebhaBeadsWidgetState extends ConsumerState<SebhaBeadsWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final CurvedAnimation _curve;

  // Configuration
  static const int _beadCount = 5; // Adjustable: 7-10 -> Reduced to 5
  static const double _beadSize =
      50.0; // REDUCED SIZE per user request (was 80.0)

  // State
  List<Offset> _slots = [];
  List<Offset> _fromPos = [];
  List<Offset> _toPos = [];

  int _pendingSteps = 0;
  bool _isAnimating = false;

  // Cache for layout checks
  Size? _lastSize;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _curve = CurvedAnimation(parent: _c, curve: Curves.easeInOutCubic);

    _c.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isAnimating = false;
        // Apply final positions
        _fromPos = List.of(_toPos);

        if (_pendingSteps > 0) {
          _pendingSteps--;
          _startOneStepAnimation();
        }
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Rebuilds the slot positions based on the current available size.
  void _rebuildSlots(Size size) {
    if (size == _lastSize && _slots.isNotEmpty) return;
    _lastSize = size;

    // 1. Calculate Scale & Offset
    double scale = min(size.width / 1080, size.height / 1080);
    double offsetX = (size.width - (1080 * scale)) / 2;
    double offsetY = (size.height - (1080 * scale)) / 2;

    // 2. Get Path
    Path basePath = SebhaPath.getPath();
    Matrix4 matrix = Matrix4.identity()
      ..translate(offsetX, offsetY)
      ..scale(scale);
    Path scaledPath = basePath.transform(matrix.storage);

    // 3. Compute Center Line
    // The path is an OUTLINE (Loop). We want the CENTER.
    // Logic: Sample points, bucket by X, Average Y.

    final metrics = scaledPath.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final m = metrics.first;
    final length = m.length;

    // Grid size for bucketing (smaller = more precision, but needs enough samples)
    final int bucketSize = 2;
    Map<int, List<double>> xBuckets = {};

    // Sample densely
    int samples = (length * 2).toInt(); // 2 samples per pixel approx
    for (int i = 0; i < samples; i++) {
      final t = i / (samples - 1);
      final pos = m.getTangentForOffset(length * t)?.position;
      if (pos != null) {
        int bucket = (pos.dx / bucketSize).round() * bucketSize;
        xBuckets.putIfAbsent(bucket, () => []).add(pos.dy);
      }
    }

    // Generate averages
    List<Offset> centerLine = [];
    List<int> sortedXs = xBuckets.keys.toList()..sort();

    for (int x in sortedXs) {
      List<double> ys = xBuckets[x]!;
      double avgY = ys.reduce((a, b) => a + b) / ys.length;
      // Fine-tune Y offset if needed (visual correction)
      // Previous observation: beads might be slightly low/high.
      // Let's add a small offset if user complained about "not exactly on path".
      // Assuming SVG path center is correct, no offset needed yet.
      // But let's add a tweak constant:
      double tweakY = -10.0 * scale;
      centerLine.add(Offset(x.toDouble(), avgY + tweakY));
    }

    // 4. Distribute Beads along this new Center Line
    if (centerLine.isEmpty) return;

    // Calculate cumulative lengths of center line segments
    List<double> lengths = [0];
    for (int i = 0; i < centerLine.length - 1; i++) {
      lengths.add(lengths.last + (centerLine[i + 1] - centerLine[i]).distance);
    }
    final totalLen = lengths.last;

    // CUSTOM SPACING LOGIC
    // config
    // User Feedback: "Increase the spacing between the 5 beads"
    double tightSpacing = _beadSize * 1.1; // Increased from 0.70 to 1.1

    // Start from 18% padding
    double currentDist = totalLen * 0.18;

    // Generate N+1 Slots (5 Visible + 1 Exit Target)
    int totalSlots = _beadCount + 1;

    // We generate positions for ALL potential slots (Visible + Exit)
    List<Offset> allSlots = List.generate(totalSlots, (i) {
      double targetDist;

      if (i == 0) {
        targetDist = currentDist;
      } else if (i < _beadCount) {
        // Visible beads (Indices 1..4) -> All get EQUAL spacing now
        currentDist += tightSpacing;
        targetDist = currentDist;
      } else if (i >= _beadCount) {
        // The EXIT bead (Index 5+)
        // Should be far off to the right
        currentDist += _beadSize * 2.5; // Push it off screen
        targetDist = currentDist;
      } else {
        // Fallback code (should not reach here)
        currentDist += tightSpacing;
        targetDist = currentDist;
      }

      // Clamp to path length
      if (targetDist > totalLen) targetDist = totalLen;

      // Find segment
      int index = 0;
      for (int k = 0; k < lengths.length - 1; k++) {
        if (targetDist >= lengths[k] && targetDist <= lengths[k + 1]) {
          index = k;
          break;
        }
      }

      // Interpolate
      double segmentLen = lengths[index + 1] - lengths[index];
      double segmentT = (segmentLen == 0)
          ? 0
          : (targetDist - lengths[index]) / segmentLen;

      Offset p1 = centerLine[index];
      Offset p2 = centerLine[index + 1];

      return Offset.lerp(p1, p2, segmentT)!;
    });

    _slots =
        allSlots; // Now contains 6 positions. 0..4 are onscreen, 5 is exit.

    // Initial positions for IDLE state
    // We strictly want to show N beads (0..4) at their slots.
    // The (N+1)th bead (Index 5) is theoretically at "Exit", but we can just map it to ExitPos.
    _fromPos = List.generate(totalSlots, (i) {
      return _slots[i];
    });
    _toPos = List.of(_fromPos);
  }

  void _onTap() {
    // 1. Update Logic (Riverpod) - Immediate
    ref.read(sebhaProvider.notifier).increment();

    // 2. Queue Animation - Visual
    _pendingSteps++;
    if (!_isAnimating) {
      _pendingSteps--; // Consume one
      _startOneStepAnimation();
    }
  }

  void _startOneStepAnimation() {
    if (_slots.isEmpty) return;

    _isAnimating = true;
    _c.stop();
    _c.reset();

    // Conveyor Belt N+1 Logic:
    // We have N+1 Widgets (Indices 0..N).
    // Widget 0: Moves Entry -> Slot[0]
    // Widget 1: Moves Slot[0] -> Slot[1]
    // ...
    // Widget N: Moves Slot[N-1] -> Slot[N] (The Exit Slot)

    int nPlus1 = _beadCount + 1;

    _fromPos = List.generate(nPlus1, (i) {
      if (i == 0) return _entryPosition();
      return _slots[i - 1]; // Start at previous slot
    });

    _toPos = List.generate(nPlus1, (i) {
      return _slots[i]; // End at current slot
    });

    _c.forward(from: 0.0);
    setState(() {});
  }

  Offset _entryPosition() {
    if (_slots.isEmpty) return Offset.zero;
    // Rough logic to place entry offscreen left
    final p0 = _slots[0];
    final p1 = _slots[min(1, _slots.length - 1)];
    Offset dir = p1 - p0;
    double dist = dir.distance;
    if (dist == 0) return p0 - Offset(_beadSize, 0);

    // Go backwards from p0
    Offset back = p0 - (dir / dist) * (_beadSize * 1.5);
    return back;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 1. Build Slots based on size
        _rebuildSlots(Size(constraints.maxWidth, constraints.maxHeight));

        // 2. Scale for Assets (needed for Background)
        double scale = min(
          constraints.maxWidth / 1080,
          constraints.maxHeight / 1080,
        );
        double offsetX = (constraints.maxWidth - (1080 * scale)) / 2;
        double offsetY = (constraints.maxHeight - (1080 * scale)) / 2;

        return GestureDetector(
          onTap: _onTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // A. Background Path (SVG Asset)
              Positioned(
                left: offsetX,
                top: offsetY,
                width: 1080 * scale,
                height: 1080 * scale,
                child: SvgPicture.asset('assets/images/spha_path.svg'),
              ),

              // B. Animated Beads
              AnimatedBuilder(
                animation: _curve,
                builder: (context, child) {
                  // We now render N+1 beads to handle the entering/exiting ones
                  return Stack(
                    clipBehavior: Clip.none,
                    children: List.generate(_beadCount + 1, (i) {
                      // Lerp logic
                      Offset start = _fromPos.length > i
                          ? _fromPos[i]
                          : Offset.zero;
                      Offset end = _toPos.length > i ? _toPos[i] : Offset.zero;

                      // Safety
                      if (start == Offset.zero || end == Offset.zero) {
                        return SizedBox.shrink();
                      }

                      Offset p = Offset.lerp(start, end, _curve.value)!;

                      // Optimization: Don't render if WAY off screen?
                      // But "Clip.none" handles it efficiently mostly.

                      return Positioned(
                        left: p.dx - (_beadSize / 2),
                        top: p.dy - (_beadSize / 2),
                        child: Image.asset(
                          'assets/images/bead.png',
                          width: _beadSize,
                          height: _beadSize,
                          // filterQuality: FilterQuality.high, // Keep high quality
                          // fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.error,
                              color: Colors.red,
                              size: _beadSize,
                            );
                          },
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
