import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sketch_table/models/models.dart';
import 'package:sketch_table/screens/story_player/story_player_screen.dart';
import 'package:sketch_table/services/story_service.dart';
import 'package:sketch_table/state/app_state.dart';
import 'package:sketch_table/utils/app_config.dart';
import 'package:sketch_table/widgets/squash_stretch_character.dart';
import 'package:sketch_table/widgets/story_player/story_canvas_view.dart';

void main() {
  group('CharacterSlotTemplate Tests', () {
    test('CharacterSlotTemplate fromJson and toJson serialization', () {
      final json = {
        'id': 'slot-uuid-1234',
        'storyPageId': 'page-uuid-5678',
        'storyRoleTemplateId': 'role-hero-9999',
        'posX': 65.5,
        'posY': 60.0,
        'scale': 1.15,
        'flipHorizontal': true,
        'status': 1,
      };

      final slot = CharacterSlotTemplate.fromJson(json);

      expect(slot.id, 'slot-uuid-1234');
      expect(slot.storyPageId, 'page-uuid-5678');
      expect(slot.storyRoleTemplateId, 'role-hero-9999');
      expect(slot.posX, 65.5);
      expect(slot.posY, 60.0);
      expect(slot.scale, 1.15);
      expect(slot.flipHorizontal, true);
      expect(slot.status, 1);

      final outJson = slot.toJson();
      expect(outJson['id'], 'slot-uuid-1234');
      expect(outJson['storyPageId'], 'page-uuid-5678');
      expect(outJson['posX'], 65.5);
      expect(outJson['flipHorizontal'], true);
    });

    test('CharacterSlotTemplate copyWith correctly modifies coordinates', () {
      const slot = CharacterSlotTemplate(
        id: 'slot-1',
        storyPageId: 'page-1',
        posX: 40.0,
        posY: 80.0,
      );

      final updated = slot.copyWith(
        posX: 72.0,
        posY: 60.0,
        scale: 1.25,
        flipHorizontal: true,
      );

      expect(updated.id, 'slot-1');
      expect(updated.posX, 72.0);
      expect(updated.posY, 60.0);
      expect(updated.scale, 1.25);
      expect(updated.flipHorizontal, true);
    });

    test('AppConfig Swagger Slot endpoints generation', () {
      const pageId = 'test-page-id';
      const slotId = 'test-slot-id';

      expect(
        AppConfig.storyPageSlotsUrl(pageId),
        '${AppConfig.baseUrl}/api/story-pages/$pageId/slots',
      );
      expect(
        AppConfig.storyPageCreateSlotUrl(pageId),
        '${AppConfig.baseUrl}/api/story-pages/$pageId/slot',
      );
      expect(
        AppConfig.storySlotUrl(slotId),
        '${AppConfig.baseUrl}/api/story-slots/$slotId',
      );
    });
  });

  group('Content Manager Percentage Stage & Animation Engine Tests', () {
    test('SlotRenderState.computeStageRect maps 0..100% center-anchored coordinates accurately', () {
      const state = SlotRenderState(
        x: 67.0,
        y: 60.0,
        scale: 1.05,
      );
      const stageSize = Size(800.0, 450.0); // 16:9 stage

      final rect = state.computeStageRect(stageSize, anchor: 'center');

      // Width = 24% of 800 * 1.05 = 201.6
      expect(rect.width, closeTo(201.6, 0.01));
      expect(rect.height, closeTo(201.6, 0.01));
      // Center must sit at (67% of 800 = 536, 60% of 450 = 270), NOT raw 67px!
      expect(rect.center.dx, closeTo(536.0, 0.01));
      expect(rect.center.dy, closeTo(270.0, 0.01));
    });

    test('StoryAnimationEngine evaluates Web FE presets (appear, walk, move, jump, spin)', () {
      const slot = CharacterSlotTemplate(
        id: 'slot-bobby-1',
        storyPageId: 'page-bobby-1',
        posX: 67.0,
        posY: 60.0,
        scale: 1.0,
      );

      final clips = StoryAnimationClip.migrateSequenceToClips([
        {'id': 'm1', 'slotId': 'slot-bobby-1', 'preset': 'appear', 'durationMs': 600},
        {'id': 'm2', 'slotId': 'slot-bobby-1', 'preset': 'jump', 'durationMs': 1000, 'params': {'distance': 10}},
        {'id': 'm3', 'slotId': 'slot-bobby-1', 'preset': 'move', 'durationMs': 800, 'params': {'distance': 8}},
      ]);

      // Start of appear (0ms) -> opacity 0
      final t0 = StoryAnimationEngine.evaluateSlotAnimation(slot, clips, 0);
      expect(t0.opacity, closeTo(0.0, 0.01));

      // Midpoint of jump (600 + 500 = 1100ms) -> y lifted up by 10% (60 - 10 = 50)
      final tMidJump = StoryAnimationEngine.evaluateSlotAnimation(slot, clips, 1100);
      expect(tMidJump.opacity, closeTo(1.0, 0.01));
      expect(tMidJump.y, closeTo(50.0, 0.05));

      // End of sequence (2400ms) -> landed back at y=60, x moved to 67 + 8 = 75
      final tEnd = StoryAnimationEngine.evaluateSlotAnimation(slot, clips, 2400);
      expect(tEnd.y, closeTo(60.0, 0.01));
      expect(tEnd.x, closeTo(75.0, 0.01));
    });

    test('StoryAnimationEngine evaluates keyframes and drawn path clips', () {
      const slot = CharacterSlotTemplate(
        id: 'slot-path',
        storyPageId: 'page-1',
        posX: 20.0,
        posY: 70.0,
      );

      const pathClip = StoryAnimationClip(
        id: 'clip-path',
        targetId: 'slot-path',
        kind: 'path',
        startMs: 0,
        durationMs: 1000,
        points: [
          StoryAnimationPoint(x: 20.0, y: 70.0),
          StoryAnimationPoint(x: 60.0, y: 70.0),
          StoryAnimationPoint(x: 60.0, y: 40.0),
        ],
      );

      // Total path length = 40 + 30 = 70. At 500ms (progress 0.5 -> distance 35), point is (55, 70).
      final mid = StoryAnimationEngine.evaluateSlotAnimation(slot, [pathClip], 500);
      expect(mid.x, closeTo(55.0, 0.01));
      expect(mid.y, closeTo(70.0, 0.01));

      final end = StoryAnimationEngine.evaluateSlotAnimation(slot, [pathClip], 1000);
      expect(end.x, closeTo(60.0, 0.01));
      expect(end.y, closeTo(40.0, 0.01));
    });

    test('CM slot-to-slot movement walks visibly across stage and respects distant prevSlot & multi-slot waypoints', () {
      const bobbyStoryId = '21a89526-20b1-471b-bce0-bc23c4fb7418';
      final roles = StoryService.getDefaultRolesForStory(
        bobbyStoryId,
        storyTitle: 'Bobby và món quà của khu vườn',
      );
      expect(roles, isNotEmpty);
      expect(roles.first.allowCustomCharacter, isTrue);

      final p3Slots = StoryService.getDefaultSlotsForPage(
        '8151605a-1d43-4d7b-9a51-71abd97f04f0',
        pageNumber: 3,
        storyId: bobbyStoryId,
      );
      final p4Slots = StoryService.getDefaultSlotsForPage(
        '782a765f-c333-417b-8b41-0addce91ff07',
        pageNumber: 4,
        storyId: bobbyStoryId,
      );

      // Case 1: Near coordinates across new scenes (< 24%) -> enters visibly across ~40% width (28% -> 68%)
      final nearClips = StoryAnimationEngine.buildContextualClipsForSlots(
        slots: p4Slots,
        previousSlots: p3Slots,
        pageNumber: 4,
        storyTitle: 'Bobby và món quà của khu vườn',
      );
      final nearStart = StoryAnimationEngine.evaluateSlotAnimation(p4Slots.first, nearClips, 0);
      final nearArrived = StoryAnimationEngine.evaluateSlotAnimation(p4Slots.first, nearClips, 2000);
      final nearEnd = StoryAnimationEngine.evaluateSlotAnimation(
        p4Slots.first,
        nearClips,
        StoryAnimationEngine.animationDuration(nearClips),
      );
      expect(nearStart.x, closeTo(28.0, 0.01));
      expect(nearArrived.x, closeTo(68.0, 0.01));
      expect(nearEnd.x, closeTo(68.0, 0.01));
      expect(nearEnd.y, closeTo(60.0, 0.01));

      // Case 2: Distant CM coordinates across pages (>= 24%) -> walks directly from prevSlot (20%) to slot (68%)
      final farPrev = [p3Slots.first.copyWith(posX: 20.0, posY: 65.0)];
      final farClips = StoryAnimationEngine.buildContextualClipsForSlots(
        slots: p4Slots,
        previousSlots: farPrev,
        pageNumber: 4,
        storyTitle: 'Bobby và món quà của khu vườn',
      );
      final farStart = StoryAnimationEngine.evaluateSlotAnimation(p4Slots.first, farClips, 0);
      final farEnd = StoryAnimationEngine.evaluateSlotAnimation(
        p4Slots.first,
        farClips,
        StoryAnimationEngine.animationDuration(farClips),
      );
      expect(farStart.x, closeTo(20.0, 0.01));
      expect(farStart.y, closeTo(65.0, 0.01));
      expect(farEnd.x, closeTo(68.0, 0.01));
      expect(farEnd.y, closeTo(60.0, 0.01));

      // Case 3: Multiple CM slots for same role on 1 page -> collapses into sequential path waypoints
      const wp1 = CharacterSlotTemplate(
        id: 'wp-1',
        storyPageId: 'page-1',
        storyRoleTemplateId: 'role-1',
        posX: 18.0,
        posY: 65.0,
      );
      const wp2 = CharacterSlotTemplate(
        id: 'wp-2',
        storyPageId: 'page-1',
        storyRoleTemplateId: 'role-1',
        posX: 74.0,
        posY: 55.0,
      );
      final collapsed = StoryAnimationEngine.collapseRoleWaypoints([wp1, wp2]);
      expect(collapsed.length, 1);
      final wpStart = StoryAnimationEngine.evaluateSlotAnimation(collapsed.first, const [], 0);
      final wpEnd = StoryAnimationEngine.evaluateSlotAnimation(collapsed.first, const [], 2500);
      expect(wpStart.x, closeTo(18.0, 0.01));
      expect(wpEnd.x, closeTo(74.0, 0.01));
      expect(wpEnd.y, closeTo(55.0, 0.01));
    });

    testWidgets('StoryCanvasView renders Dragon heroCharacter inside CM slot and replays motion', (tester) async {
      const bobbySlot = CharacterSlotTemplate(
        id: 'dbd4550d-7d06-4515-9676-cb0eaa69770b',
        storyPageId: 'b9e0a450-f357-48b5-a27d-b31ce11df38d',
        storyRoleTemplateId: '11911ece-1f1e-4134-8c27-978f24623c4a',
        posX: 67.0,
        posY: 60.0,
        scale: 1.05,
      );

      bool replayed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoryCanvasView(
              screenShakeOffset: 0.0,
              imageUrl: '',
              particles: const [],
              chapterTitle: 'Trang 1: Bobby và món quà của khu vườn',
              activeRoleName: 'Hiệp Sĩ Rồng Con',
              characterPosition: const Offset(40, 80),
              flipHorizontal: false,
              characterScale: 1.0,
              animationMode: AnimationMode.stateMachine3D,
              characterAction: CharacterAction.idle,
              stageSlots: const [
                StoryStageSlotItem(
                  slot: bobbySlot,
                  renderState: SlotRenderState(x: 67.0, y: 60.0, scale: 1.05),
                  imageUrl: 'assets/images/hero.webp',
                  displayName: 'Hiệp Sĩ Rồng Con',
                  speechPhrase: 'Chào bé! Tớ là Hiệp Sĩ Rồng Con!',
                ),
              ],
              onScreenShake: () {},
              onPositionChanged: (_) {},
              onDragEndPosition: (_) {},
              onActionChanged: (_) {},
              onTapSparkles: () {},
              onReplayMotion: () => replayed = true,
            ),
          ),
        ),
      );

      if (StoryCanvasView.showCanvasBadges) {
        expect(find.text('Hiệp Sĩ Rồng Con'), findsOneWidget);
        expect(find.text('Xem lại'), findsOneWidget);

        await tester.tap(find.text('Xem lại'));
        await tester.pump();
        expect(replayed, isTrue);
      }
    });

    testWidgets('StoryPlayerScreen continuously moves Dragon along CM coordinates and survives hot reload', (tester) async {
      final appState = AppState();
      final bobbyTemplate = StoryService.defaultStoryTemplates.firstWhere(
        (t) => t.id == '21a89526-20b1-471b-bce0-bc23c4fb7418',
      );
      final story = bobbyTemplate.toStory();

      await tester.pumpWidget(
        MaterialApp(
          home: StoryPlayerScreen(
            appState: appState,
            story: story,
          ),
        ),
      );
      await tester.pump();

      // Dragon heroCharacter is rendered in the CM slot
      if (StoryCanvasView.showCanvasBadges) {
        expect(find.text('Hiệp Sĩ Rồng Con'), findsOneWidget);
      }
      final slotFinder = find.byKey(const ValueKey('cm-slot-bobby-slot-1'));
      expect(slotFinder, findsOneWidget);

      final rectAtStart = tester.getRect(slotFinder);

      // Advance 1 second -> Dragon must have walked substantially rightward toward CM's posX=67%
      await tester.pump(const Duration(milliseconds: 1000));
      final rectMidWalk = tester.getRect(slotFinder);
      expect(rectMidWalk.center.dx, greaterThan(rectAtStart.center.dx + 40.0));

      // Advance past arrival (2.1s total) -> Dragon reaches CM's target coordinate
      await tester.pump(const Duration(milliseconds: 1100));
      final rectAtTarget = tester.getRect(slotFinder);
      expect(rectAtTarget.center.dx, greaterThan(rectMidWalk.center.dx + 30.0));

      // Advance into 2nd loop cycle (total 4.5s -> 0.3s into loop 2) -> Dragon is actively moving again, NOT stuck still!
      await tester.pump(const Duration(milliseconds: 2400));
      final rectSecondLoop = tester.getRect(slotFinder);
      expect((rectSecondLoop.center.dx - rectAtTarget.center.dx).abs(), greaterThan(50.0));

      // Simulate Hot Reload (reassemble) and ensure zero crash + continued movement
      tester.binding.reassembleApplication();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('cm-slot-bobby-slot-1')), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 20));
    });
  });
}
