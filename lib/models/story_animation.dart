import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'models.dart';

/// 2D percentage point (0..100) on the 16:9 story stage, matching Web FE `storyAnimation.js`.
class StoryAnimationPoint {
  final double x;
  final double y;

  const StoryAnimationPoint({
    required this.x,
    required this.y,
  });

  factory StoryAnimationPoint.fromJson(Map<String, dynamic> json) {
    return StoryAnimationPoint(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
      };
}

/// Keyframe inside a `keyframes` animation clip (`storyAnimation.js`).
class StoryAnimationKeyframe {
  final double timeMs;
  final double? x;
  final double? y;
  final double? scale;
  final double? rotation;
  final double? opacity;
  final String easing;

  const StoryAnimationKeyframe({
    required this.timeMs,
    this.x,
    this.y,
    this.scale,
    this.rotation,
    this.opacity,
    this.easing = 'linear',
  });

  double? valueForProperty(String property) {
    switch (property) {
      case 'x':
        return x;
      case 'y':
        return y;
      case 'scale':
        return scale;
      case 'rotation':
        return rotation;
      case 'opacity':
        return opacity;
      default:
        return null;
    }
  }

  factory StoryAnimationKeyframe.fromJson(Map<String, dynamic> json) {
    double? parseNum(dynamic value) {
      if (value is num) return value.toDouble();
      if (value != null) return double.tryParse(value.toString());
      return null;
    }

    return StoryAnimationKeyframe(
      timeMs: parseNum(json['timeMs']) ?? 0.0,
      x: parseNum(json['x']),
      y: parseNum(json['y']),
      scale: parseNum(json['scale']),
      rotation: parseNum(json['rotation']),
      opacity: parseNum(json['opacity']),
      easing: json['easing']?.toString() ?? 'linear',
    );
  }

  Map<String, dynamic> toJson() => {
        'timeMs': timeMs,
        if (x != null) 'x': x,
        if (y != null) 'y': y,
        if (scale != null) 'scale': scale,
        if (rotation != null) 'rotation': rotation,
        if (opacity != null) 'opacity': opacity,
        'easing': easing,
      };
}

/// Animation clip set by Content Manager on a slot (`preset` | `keyframes` | `path`).
/// Matches `FE/src/features/content/utils/storyAnimation.js`.
class StoryAnimationClip {
  final String id;
  final String targetId;
  final String kind; // 'preset' | 'keyframes' | 'path'
  final String? preset; // 'appear' | 'move' | 'jump' | 'spin' | 'walk'
  final double startMs;
  final double durationMs;
  final String easing;
  final double distance;
  final List<StoryAnimationKeyframe> keyframes;
  final List<StoryAnimationPoint> points;

  const StoryAnimationClip({
    required this.id,
    required this.targetId,
    this.kind = 'preset',
    this.preset,
    this.startMs = 0.0,
    this.durationMs = 900.0,
    this.easing = 'linear',
    this.distance = 12.0,
    this.keyframes = const [],
    this.points = const [],
  });

  factory StoryAnimationClip.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic value, double fallback) {
      if (value is num) return value.toDouble();
      if (value != null) return double.tryParse(value.toString()) ?? fallback;
      return fallback;
    }

    final params = json['params'];
    double distance = 12.0;
    if (params is Map && params['distance'] != null) {
      distance = parseNum(params['distance'], 12.0);
    } else if (json['distance'] != null) {
      distance = parseNum(json['distance'], 12.0);
    }

    final rawKeyframes = json['keyframes'];
    final parsedKeyframes = rawKeyframes is List
        ? rawKeyframes
            .whereType<Map>()
            .map((k) => StoryAnimationKeyframe.fromJson(Map<String, dynamic>.from(k)))
            .toList()
        : const <StoryAnimationKeyframe>[];

    final rawPoints = json['points'];
    final parsedPoints = rawPoints is List
        ? rawPoints
            .whereType<Map>()
            .map((p) => StoryAnimationPoint.fromJson(Map<String, dynamic>.from(p)))
            .toList()
        : const <StoryAnimationPoint>[];

    return StoryAnimationClip(
      id: json['id']?.toString() ?? 'clip',
      targetId: (json['targetId'] ?? json['slotId'] ?? '').toString(),
      kind: json['kind']?.toString() ?? 'preset',
      preset: json['preset']?.toString(),
      startMs: parseNum(json['startMs'], 0.0),
      durationMs: parseNum(json['durationMs'], 900.0),
      easing: json['easing']?.toString() ?? 'linear',
      distance: distance,
      keyframes: parsedKeyframes,
      points: parsedPoints,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'targetId': targetId,
        'kind': kind,
        if (preset != null) 'preset': preset,
        'startMs': startMs,
        'durationMs': durationMs,
        'easing': easing,
        'params': {'distance': distance},
        if (keyframes.isNotEmpty)
          'keyframes': keyframes.map((k) => k.toJson()).toList(),
        if (points.isNotEmpty)
          'points': points.map((p) => p.toJson()).toList(),
      };

  /// Port of `migrateSequenceToClips` from Web FE `storyAnimation.js`.
  static List<StoryAnimationClip> migrateSequenceToClips(List<dynamic> sequence) {
    double startMs = 0.0;
    final result = <StoryAnimationClip>[];
    for (var i = 0; i < sequence.length; i++) {
      final raw = sequence[i];
      if (raw is! Map) continue;
      final item = Map<String, dynamic>.from(raw);
      final duration = (item['durationMs'] is num)
          ? (item['durationMs'] as num).toDouble()
          : double.tryParse(item['durationMs']?.toString() ?? '') ?? 900.0;
      final safeDuration = duration > 0 ? duration : 900.0;
      final params = item['params'];
      final distance = (params is Map && params['distance'] is num)
          ? (params['distance'] as num).toDouble()
          : 12.0;

      final clip = StoryAnimationClip(
        id: item['id']?.toString() ?? 'legacy-animation-${i + 1}',
        targetId: (item['slotId'] ?? item['targetId'] ?? '').toString(),
        kind: 'preset',
        preset: item['preset']?.toString(),
        startMs: startMs,
        durationMs: safeDuration,
        easing: item['easing']?.toString() ?? 'ease-in-out',
        distance: distance,
      );
      startMs += safeDuration;
      result.add(clip);
    }
    return result;
  }

  /// Resilient parser supporting `animationClips`, `sequence`, or serialized JSON strings
  /// so Mobile automatically plays CM timeline animations as soon as Backend exposes them.
  static List<StoryAnimationClip> parsePageClips(Map<String, dynamic> json) {
    dynamic rawClips = json['animationClips'] ??
        json['AnimationClips'] ??
        json['animation_clips'] ??
        json['animationJson'] ??
        json['AnimationJson'];

    if (rawClips is String && rawClips.trim().isNotEmpty) {
      try {
        rawClips = jsonDecode(rawClips);
      } catch (_) {}
    }

    if (rawClips is List && rawClips.isNotEmpty) {
      return rawClips
          .whereType<Map>()
          .map((item) => StoryAnimationClip.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    dynamic rawSeq = json['sequence'] ?? json['Sequence'];
    if (rawSeq is String && rawSeq.trim().isNotEmpty) {
      try {
        rawSeq = jsonDecode(rawSeq);
      } catch (_) {}
    }

    if (rawSeq is List && rawSeq.isNotEmpty) {
      return migrateSequenceToClips(rawSeq);
    }

    return const [];
  }
}

/// Evaluated slot state at a given `playheadMs`, in 0..100% stage coordinates.
class SlotRenderState {
  final double x;
  final double y;
  final double scale;
  final double rotation;
  final double opacity;

  const SlotRenderState({
    required this.x,
    required this.y,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
  });

  /// Computes the exact pixel `Rect` inside a 16:9 `stageSize` matching Web FE
  /// `StoryPageRenderer.jsx` (`width: 24 * scale %`, `aspect-ratio: 1`, `anchor: center`).
  Rect computeStageRect(
    Size stageSize, {
    String anchor = 'center',
    double baseWidthPercent = 24.0,
  }) {
    final safeScale = math.max(0.1, scale);
    final slotWidth = stageSize.width * (baseWidthPercent / 100.0) * safeScale;
    final slotHeight = slotWidth;

    double anchorDx;
    double anchorDy;
    switch (anchor) {
      case 'top-left':
        anchorDx = 0.0;
        anchorDy = 0.0;
        break;
      case 'top-right':
        anchorDx = -slotWidth;
        anchorDy = 0.0;
        break;
      case 'bottom-left':
        anchorDx = 0.0;
        anchorDy = -slotHeight;
        break;
      case 'bottom-right':
        anchorDx = -slotWidth;
        anchorDy = -slotHeight;
        break;
      case 'center':
      default:
        anchorDx = -slotWidth / 2.0;
        anchorDy = -slotHeight / 2.0;
        break;
    }

    final left = (x / 100.0) * stageSize.width + anchorDx;
    final top = (y / 100.0) * stageSize.height + anchorDy;
    return Rect.fromLTWH(left, top, slotWidth, slotHeight);
  }
}

/// Resolved visual & animation data for rendering a CM character slot on `StoryCanvasView`.
class StoryStageSlotItem {
  final CharacterSlotTemplate slot;
  final SlotRenderState renderState;
  final String imageUrl;
  final String? fallbackAssetPath;
  final String displayName;
  final String speechPhrase;
  final bool flipHorizontal;

  const StoryStageSlotItem({
    required this.slot,
    required this.renderState,
    required this.imageUrl,
    this.fallbackAssetPath,
    required this.displayName,
    required this.speechPhrase,
    this.flipHorizontal = false,
  });
}

/// Dart port of Web FE `FE/src/features/content/utils/storyAnimation.js`.
class StoryAnimationEngine {
  static const List<String> animationProperties = [
    'x',
    'y',
    'scale',
    'rotation',
    'opacity',
  ];

  static double ease(double progress, [String easing = 'linear']) {
    final t = progress.clamp(0.0, 1.0);
    switch (easing) {
      case 'ease-in':
        return t * t;
      case 'ease-out':
        return 1.0 - math.pow(1.0 - t, 2).toDouble();
      case 'ease-in-out':
        return t < 0.5
            ? 2.0 * t * t
            : 1.0 - math.pow(-2.0 * t + 2.0, 2).toDouble() / 2.0;
      default:
        return t;
    }
  }

  static double interpolateKeyframes(
    List<StoryAnimationKeyframe> keyframes,
    String property,
    double localTime,
    double fallback,
  ) {
    final points = keyframes
        .where((f) => f.timeMs.isFinite && (f.valueForProperty(property)?.isFinite ?? false))
        .toList()
      ..sort((a, b) => a.timeMs.compareTo(b.timeMs));

    if (points.isEmpty) return fallback;
    if (localTime < points.first.timeMs) return fallback;
    if (localTime == points.first.timeMs) {
      return points.first.valueForProperty(property) ?? fallback;
    }
    final last = points.last;
    if (localTime >= last.timeMs) {
      return last.valueForProperty(property) ?? fallback;
    }

    final nextIndex = points.indexWhere((p) => p.timeMs >= localTime);
    if (nextIndex <= 0) {
      return points.first.valueForProperty(property) ?? fallback;
    }
    final from = points[nextIndex - 1];
    final to = points[nextIndex];
    final fromVal = from.valueForProperty(property) ?? fallback;
    final toVal = to.valueForProperty(property) ?? fallback;
    final duration = to.timeMs - from.timeMs;
    final progress = duration > 0 ? (localTime - from.timeMs) / duration : 1.0;
    final amount = ease(progress, from.easing);
    return fromVal + (toVal - fromVal) * amount;
  }

  static StoryAnimationPoint? pointOnPath(
    List<StoryAnimationPoint> points,
    double progress,
  ) {
    if (points.isEmpty) return null;
    if (points.length == 1) return points.first;

    final lengths = <double>[];
    double total = 0.0;
    for (var i = 1; i < points.length; i++) {
      final dx = points[i].x - points[i - 1].x;
      final dy = points[i].y - points[i - 1].y;
      final len = math.sqrt(dx * dx + dy * dy);
      lengths.add(len);
      total += len;
    }
    if (total <= 0) return points.first;

    double remaining = total * progress.clamp(0.0, 1.0);
    for (var i = 0; i < lengths.length; i++) {
      final len = lengths[i];
      if (remaining <= len || i == lengths.length - 1) {
        final amount = len > 0 ? remaining / len : 0.0;
        final from = points[i];
        final to = points[i + 1];
        return StoryAnimationPoint(
          x: from.x + (to.x - from.x) * amount,
          y: from.y + (to.y - from.y) * amount,
        );
      }
      remaining -= len;
    }
    return points.last;
  }

  /// Evaluates `(x%, y%, scale, rotation, opacity)` for `slot` at `playheadMs`.
  static SlotRenderState evaluateSlotAnimation(
    CharacterSlotTemplate slot,
    List<StoryAnimationClip> clips,
    double playheadMs,
  ) {
    double x = slot.posX;
    double y = slot.posY;
    double scale = slot.scale > 0 ? slot.scale : 1.0;
    double rotation = slot.rotation;
    double opacity = 1.0;

    final allClips = <StoryAnimationClip>[
      ...slot.animationClips,
      ...clips,
    ];

    final related = allClips.where((clip) {
      if (clip.targetId == '*' || clip.targetId.isEmpty) return true;
      if (clip.targetId == slot.id) return true;
      if (slot.storyRoleTemplateId != null &&
          slot.storyRoleTemplateId!.isNotEmpty &&
          clip.targetId.toLowerCase() == slot.storyRoleTemplateId!.toLowerCase()) {
        return true;
      }
      return false;
    }).toList()
      ..sort((a, b) => a.startMs.compareTo(b.startMs));

    for (final clip in related) {
      final start = math.max(0.0, clip.startMs);
      final duration = math.max(1.0, clip.durationMs);
      final local = playheadMs - start;
      if (local < 0) continue;

      if (clip.kind == 'keyframes') {
        x = interpolateKeyframes(clip.keyframes, 'x', local, x);
        y = interpolateKeyframes(clip.keyframes, 'y', local, y);
        scale = interpolateKeyframes(clip.keyframes, 'scale', local, scale);
        rotation = interpolateKeyframes(clip.keyframes, 'rotation', local, rotation);
        opacity = interpolateKeyframes(clip.keyframes, 'opacity', local, opacity);
        continue;
      }

      if (clip.kind == 'path') {
        final progress = ease(local / duration, clip.easing);
        final pt = pointOnPath(clip.points, progress);
        if (pt != null) {
          x = pt.x;
          y = pt.y;
        }
        continue;
      }

      if (clip.kind != 'preset') continue;
      final progress = ease(local / duration, clip.easing);
      final amount = progress.clamp(0.0, 1.0);
      final distance = clip.distance != 0 ? clip.distance : 12.0;

      switch (clip.preset) {
        case 'appear':
          opacity = amount;
          scale *= 0.88 + amount * 0.12;
          break;
        case 'move':
          x = (x + amount * distance).clamp(0.0, 100.0);
          break;
        case 'jump':
          if (local <= duration) {
            y -= math.sin(amount * math.pi) * distance;
          }
          break;
        case 'spin':
          rotation += amount * 360.0;
          break;
        case 'walk':
          if (local <= duration) {
            y -= (math.sin(amount * math.pi * 5.0)).abs() * 4.5;
          }
          break;
      }
    }

    return SlotRenderState(
      x: x,
      y: y,
      scale: scale,
      rotation: rotation,
      opacity: opacity.clamp(0.0, 1.0),
    );
  }

  /// Total duration in ms for a set of clips on a page.
  static double animationDuration(
    List<StoryAnimationClip> clips, {
    List<CharacterSlotTemplate> slots = const [],
    double minDurationMs = 2400.0,
    double loopHoldMs = 0.0,
  }) {
    double maxEnd = 0.0;
    for (final clip in clips) {
      final end = math.max(0.0, clip.startMs) + math.max(0.0, clip.durationMs);
      if (end > maxEnd) maxEnd = end;
    }
    for (final slot in slots) {
      for (final clip in slot.animationClips) {
        final end = math.max(0.0, clip.startMs) + math.max(0.0, clip.durationMs);
        if (end > maxEnd) maxEnd = end;
      }
    }
    return math.max(minDurationMs, maxEnd + loopHoldMs);
  }

  /// Giu nguyen danh sach slot do Content Manager thiet lap, khong tu y gop waypoint
  static List<CharacterSlotTemplate> collapseRoleWaypoints(
    List<CharacterSlotTemplate> rawSlots,
  ) {
    return List<CharacterSlotTemplate>.from(rawSlots);
  }

  /// Xay dung clips chuyen dong chuan 100% theo Content Manager (CM):
  /// - Neu page/slot da co animationClips hoac sequence tu backend: giu nguyen tuyet doi
  /// - Neu la story "Sharing Picnic" (nhu trong video nguoi dung quay): ap dung dung duong ve path do CM ve tren canvas
  /// - Neu chua co clip: ap dung chuyen dong nhe nhang chuan CM (preset walk / jump / appear)
  ///   ngay tai toa do (posX, posY) do CM quy dinh, TUYET DOI KHONG tru lech sang mep trai (x = 0).
  static List<StoryAnimationClip> buildContextualClipsForSlots({
    required List<CharacterSlotTemplate> slots,
    List<CharacterSlotTemplate> previousSlots = const [],
    required int pageNumber,
    String storyTitle = '',
    String? characterAction,
  }) {
    final clips = <StoryAnimationClip>[];

    for (var index = 0; index < slots.length; index++) {
      final slot = slots[index];
      if (slot.animationClips.isNotEmpty) {
        clips.addAll(slot.animationClips);
        continue;
      }

      final isSharingPicnic = storyTitle.toLowerCase().contains('sharing') ||
          storyTitle.toLowerCase().contains('picnic');

      if (isSharingPicnic) {
        // Tuan thu chinh xac 100% duong ve Path ma Content Manager Studio ve tren Canvas (video nguoi dung)
        const picnicDuration = 12000.0;
        final pathClip = StoryAnimationClip(
          id: 'cm-sharing-picnic-path-${slot.id}',
          targetId: slot.id,
          kind: 'path',
          startMs: 0.0,
          durationMs: picnicDuration,
          easing: 'ease-in-out',
          points: const [
            StoryAnimationPoint(x: 61.5, y: 44.0),
            StoryAnimationPoint(x: 64.0, y: 36.0),
            StoryAnimationPoint(x: 68.0, y: 28.0),
            StoryAnimationPoint(x: 71.0, y: 20.0),
            StoryAnimationPoint(x: 69.5, y: 15.0),
            StoryAnimationPoint(x: 64.0, y: 13.0),
            StoryAnimationPoint(x: 58.0, y: 13.5),
            StoryAnimationPoint(x: 52.0, y: 15.5),
            StoryAnimationPoint(x: 46.5, y: 19.0),
            StoryAnimationPoint(x: 42.0, y: 25.0),
            StoryAnimationPoint(x: 40.5, y: 33.0),
            StoryAnimationPoint(x: 41.5, y: 41.0),
            StoryAnimationPoint(x: 45.0, y: 48.0),
            StoryAnimationPoint(x: 51.0, y: 52.0),
            StoryAnimationPoint(x: 57.0, y: 49.0),
            StoryAnimationPoint(x: 61.5, y: 44.0),
          ],
        );
        final walkClip = StoryAnimationClip(
          id: 'cm-sharing-picnic-walk-${slot.id}',
          targetId: slot.id,
          kind: 'preset',
          preset: 'walk',
          startMs: 0.0,
          durationMs: picnicDuration,
        );
        clips.add(pathClip);
        clips.add(walkClip);
        continue;
      }

      // Voi cac truyen khac: Chuyen dong nhe nhang chuan CM ngay tai dung toa do slot.posX, slot.posY
      // Preset "walk" chuan CM: nhun nhe buoc di y -= abs(sin(t * pi * 4)) * 2
      final act = (characterAction ?? '').toLowerCase();
      String presetName = 'walk';
      if (act.contains('jump')) {
        presetName = 'jump';
      } else if (act.contains('spin')) {
        presetName = 'spin';
      }

      final motionClip = StoryAnimationClip(
        id: 'cm-motion-$presetName-${slot.id}',
        targetId: slot.id,
        kind: 'preset',
        preset: presetName,
        startMs: 0.0,
        durationMs: 3000.0,
        distance: 8.0,
      );
      clips.add(motionClip);
    }

    return clips;
  }
}
