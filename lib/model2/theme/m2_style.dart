import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:udghosh/theme/neo_theme.dart';

/// Model 2's depth language.
///
/// Model 1 uses one shape (flat) at two depths. Model 2 treats the surface as
/// a physical instrument panel and commits to the full vocabulary:
///
/// * **plinth**  — a large convex slab; the thing everything else sits on
/// * **knob**    — a small convex circle that invites a press
/// * **well**    — a concave recess; things *sit inside* it
/// * **readout** — a deep emboss used only for numbers and scores
/// * **rail**    — a shallow stadium-shaped recess for chip rows
///
/// Every surface reads as one of these five, which is what keeps a
/// neumorphic UI from dissolving into undifferentiated grey mush.
class M2 {
  M2._();

  // Depth scale. Kept shallower than Model 1's on the raised side and deeper
  // on the recessed side — that asymmetry is what makes the panel read as
  // carved rather than inflated.
  static const double plinthDepth = 6;
  static const double cardDepth = 4;
  static const double knobDepth = 5;
  static const double wellDepth = -5;
  static const double readoutDepth = -7;
  static const double railDepth = -3;
  static const double chipKnobDepth = 3;
  static const double pressed = -3;

  static const double intensity = 0.7;
  static const double surfaceIntensity = 0.35;

  static const double rCard = 22;
  static const double rPanel = 28;
  static const double rWell = 16;

  /// Convex slab — the base plate of a section.
  static NeumorphicStyle plinth({
    double radius = rPanel,
    double depth = plinthDepth,
    Color? color,
  }) => NeumorphicStyle(
    shape: NeumorphicShape.convex,
    depth: depth,
    intensity: intensity,
    surfaceIntensity: surfaceIntensity,
    color: color ?? NeoColors.surface,
    lightSource: LightSource.topLeft,
    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
  );

  /// Flat raised card — for content that must stay legible (text, photos).
  static NeumorphicStyle card({
    double radius = rCard,
    double depth = cardDepth,
    Color? color,
  }) => NeumorphicStyle(
    shape: NeumorphicShape.flat,
    depth: depth,
    intensity: intensity,
    color: color ?? NeoColors.surface,
    lightSource: LightSource.topLeft,
    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
  );

  /// Concave recess — content sits *in* it.
  static NeumorphicStyle well({
    double radius = rWell,
    double depth = wellDepth,
    Color? color,
  }) => NeumorphicStyle(
    shape: NeumorphicShape.concave,
    depth: depth,
    intensity: intensity,
    surfaceIntensity: surfaceIntensity,
    color: color ?? NeoColors.surfaceRecessed,
    lightSource: LightSource.topLeft,
    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
  );

  /// Deep emboss reserved for numeric readouts — scores, counts, clocks.
  static NeumorphicStyle readout({double radius = 14}) => NeumorphicStyle(
    shape: NeumorphicShape.flat,
    depth: readoutDepth,
    intensity: intensity,
    color: NeoColors.surfaceRecessed,
    lightSource: LightSource.topLeft,
    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
  );

  /// Shallow stadium recess that a row of chips rides inside.
  static NeumorphicStyle rail() => NeumorphicStyle(
    shape: NeumorphicShape.concave,
    depth: railDepth,
    intensity: intensity,
    color: NeoColors.surfaceRecessed,
    lightSource: LightSource.topLeft,
    boxShape: const NeumorphicBoxShape.stadium(),
  );

  /// Convex circle — a physical button.
  static NeumorphicStyle knob({double depth = knobDepth, Color? color}) =>
      NeumorphicStyle(
        shape: NeumorphicShape.convex,
        depth: depth,
        intensity: intensity,
        surfaceIntensity: surfaceIntensity,
        color: color ?? NeoColors.surface,
        lightSource: LightSource.topLeft,
        boxShape: const NeumorphicBoxShape.circle(),
      );

  /// Stadium pill, raised or pressed depending on [selected].
  static NeumorphicStyle pill({required bool selected, Color? color}) =>
      NeumorphicStyle(
        shape: selected ? NeumorphicShape.flat : NeumorphicShape.convex,
        depth: selected ? pressed : cardDepth,
        intensity: intensity,
        surfaceIntensity: surfaceIntensity,
        color: color ?? NeoColors.surface,
        lightSource: LightSource.topLeft,
        boxShape: const NeumorphicBoxShape.stadium(),
      );
}
