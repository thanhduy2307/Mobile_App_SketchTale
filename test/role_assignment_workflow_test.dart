import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sketch_table/models/models.dart';
import 'package:sketch_table/screens/role_assignment/role_assignment_controller.dart';
import 'package:sketch_table/state/app_state.dart';
import 'package:sketch_table/widgets/character_cutout_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RoleAssignment Workflow Tests (CM Role Set & Default Fallback)', () {
    test('RoleAssignmentController loads all roles set by CM', () async {
      final controller = RoleAssignmentController();
      expect(controller.storyRoles, isEmpty);

      // Load roles for Bobby story (offline fallback provides 2 CM roles)
      await controller.loadStoryRoles(
        storyId: '21a89526-20b1-471b-bce0-bc23c4fb7418',
        storyTitle: 'Bobby va mon qua cua khu vuon',
      );

      expect(controller.storyRoles.isNotEmpty, true);
      expect(controller.storyRoles.length, greaterThanOrEqualTo(2));
      expect(controller.currentTargetRole, isNotNull);
      expect(controller.targetSlotIndex, 0);
    });

    test('Assigning character to role works and defaults to CM when unassigned', () async {
      final state = AppState();
      final controller = RoleAssignmentController();

      await controller.loadStoryRoles(
        storyId: '21a89526-20b1-471b-bce0-bc23c4fb7418',
        storyTitle: 'Bobby va mon qua cua khu vuon',
      );

      final role1 = controller.storyRoles[0];
      final role2 = controller.storyRoles[1];

      // Ban dau: chua gan nhan vat nao -> Ca 2 vai deu tra ve null (tu dong lay mac dinh cua CM)
      expect(controller.getAssignedCharacterForRole(state, role1, 0), isNull);
      expect(controller.getAssignedCharacterForRole(state, role2, 1), isNull);

      // Tao 1 nhan vat da duoc Ba Me duyet
      final approvedKidChar = KidCharacter(
        id: 'char-dragon-001',
        name: 'Rong Lua',
        title: 'Hiep si',
        description: 'Dung manh',
        drawingUrl: 'https://res.cloudinary.com/draw.png',
        avatar3dUrl: 'https://res.cloudinary.com/avatar.png',
        isParentApproved: true,
        voicePhrase: 'Chao cac ban!',
        themeColor: const Color(0xFFE11D48),
        createdAt: DateTime.now(),
      );
      state.characters.add(approvedKidChar);

      // Gan Rong Lua vao Vai 1
      controller.setTargetSlot(0);
      await state.assignCharacterRole(
        storyId: state.currentStory.id,
        storyRoleTemplateId: role1.id,
        characterId: approvedKidChar.id,
      );
      state.assignHeroCharacter(approvedKidChar);

      // Bay gio: Vai 1 co nhan vat be ve; Vai 2 khong du nhan vat nen tu dong lay mac dinh cua CM
      expect(controller.getAssignedCharacterForRole(state, role1, 0)?.name, 'Rong Lua');
      expect(controller.getAssignedCharacterForRole(state, role2, 1), isNull);

      // Kiem tra getAssignedRoleForCharacter
      final assignedRole = controller.getAssignedRoleForCharacter(state, approvedKidChar.id);
      expect(assignedRole?.id, role1.id);

      // Khi be bam quay lai mac dinh cua CM cho Vai 1:
      controller.resetRoleToDefault(state: state, role: role1, index: 0);
      expect(controller.getAssignedCharacterForRole(state, role1, 0), isNull);
      expect(controller.getAssignedRoleForCharacter(state, approvedKidChar.id), isNull);
    });

    test('Moving character from role 1 to role 2 automatically frees role 1 back to CM default', () async {
      final state = AppState();
      final controller = RoleAssignmentController();

      await controller.loadStoryRoles(
        storyId: '21a89526-20b1-471b-bce0-bc23c4fb7418',
        storyTitle: 'Bobby va mon qua cua khu vuon',
      );

      final role1 = controller.storyRoles[0];
      final role2 = controller.storyRoles[1];

      final char1 = KidCharacter(
        id: 'char-fox-002',
        name: 'Cao Vang',
        title: 'Thong minh',
        description: 'Nhanh nhen',
        drawingUrl: 'https://res.cloudinary.com/draw2.png',
        avatar3dUrl: 'https://res.cloudinary.com/avatar2.png',
        isParentApproved: true,
        voicePhrase: 'Xin chao!',
        themeColor: const Color(0xFFF59E0B),
        createdAt: DateTime.now(),
      );
      state.characters.add(char1);

      // Gan vao Vai 1
      await state.assignCharacterRole(
        storyId: state.currentStory.id,
        storyRoleTemplateId: role1.id,
        characterId: char1.id,
      );
      state.assignHeroCharacter(char1);
      expect(controller.getAssignedCharacterForRole(state, role1, 0)?.name, 'Cao Vang');

      // Chuyen sang Vai 2: role 1 phai duoc giai phong ve mac dinh CM
      state.clearRoleMapping(state.currentStory.id, role1.id);
      state.assignHeroCharacter(null);
      await state.assignCharacterRole(
        storyId: state.currentStory.id,
        storyRoleTemplateId: role2.id,
        characterId: char1.id,
      );
      state.assignCompanionCharacter(char1);

      expect(controller.getAssignedCharacterForRole(state, role1, 0), isNull);
      expect(controller.getAssignedCharacterForRole(state, role2, 1)?.name, 'Cao Vang');
    });

    test('CharacterCutoutImage removes solid background while preserving inner white features', () {
      const width = 9;
      const height = 9;
      final rgba = Uint8List(width * height * 4);

      void setPixel(int x, int y, int r, int g, int b, int a) {
        final idx = (y * width + x) * 4;
        rgba[idx] = r;
        rgba[idx + 1] = g;
        rgba[idx + 2] = b;
        rgba[idx + 3] = a;
      }

      int getAlpha(int x, int y) => rgba[(y * width + x) * 4 + 3];

      // 1. Toan bo nen trang (255, 255, 255, 255)
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
          setPixel(x, y, 255, 255, 255, 255);
        }
      }

      // 2. Ve than nhan vat mau do (220, 38, 38) tu (2..6, 2..6)
      for (var y = 2; y <= 6; y++) {
        for (var x = 2; x <= 6; x++) {
          setPixel(x, y, 220, 38, 38, 255);
        }
      }

      // 3. Dat 1 diem mau trang o tam (4, 4) dai dien cho long trang mat ben trong nhan vat
      setPixel(4, 4, 255, 255, 255, 255);

      final modified = CharacterCutoutImage.removeBackgroundFromRgba(rgba, width, height);
      expect(modified, isTrue);

      // Nen trang ben ngoai (0, 0) va (8, 8) phai bi xoa thanh trong suot (alpha = 0)
      expect(getAlpha(0, 0), 0);
      expect(getAlpha(8, 8), 0);
      expect(getAlpha(1, 1), 0);

      // Phan than nhan vat (3, 3) va con mat trang ben trong (4, 4) duoc bao toan alpha = 255
      expect(getAlpha(3, 3), 255);
      expect(getAlpha(4, 4), 255);
    });
  });
}
