import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/story_service.dart';
import '../../state/app_state.dart';
import '../story_player/story_player_screen.dart';
import 'dialogs/role_unapproved_warning_dialog.dart';

/// Controller Quan Ly Gan Vai Trong Truyen (RoleAssignmentController)
/// Lay toan bo vai dien do Content Manager (CM) thiet lap.
/// Be co the chon ban nho de gan vao tung vai, neu khong du ban nho thi se tu dong lay mac dinh cua CM.
class RoleAssignmentController extends ChangeNotifier {
  int targetSlotIndex = 0;
  List<StoryRoleTemplate> storyRoles = [];
  bool isLoadingRoles = false;

  int get targetSlot => targetSlotIndex + 1;

  void setTargetSlot(int index) {
    final maxIndex = storyRoles.isNotEmpty ? storyRoles.length - 1 : 0;
    final clamped = index.clamp(0, maxIndex);
    if (targetSlotIndex == clamped) return;
    targetSlotIndex = clamped;
    notifyListeners();
  }

  Future<void> loadStoryRoles({
    required String storyId,
    String? token,
    String? storyTitle,
  }) async {
    isLoadingRoles = true;
    notifyListeners();
    try {
      final roles = await StoryService.fetchStoryRoles(
        storyId,
        token: token,
        storyTitle: storyTitle,
      );
      if (roles.isNotEmpty) {
        storyRoles = roles;
      } else {
        storyRoles = StoryService.getDefaultRolesForStory(
          storyId,
          storyTitle: storyTitle,
        );
      }
    } catch (e) {
      debugPrint('[RoleAssignmentController] Error loading roles: $e');
      storyRoles = StoryService.getDefaultRolesForStory(
        storyId,
        storyTitle: storyTitle,
      );
    } finally {
      isLoadingRoles = false;
      if (storyRoles.isNotEmpty && targetSlotIndex >= storyRoles.length) {
        targetSlotIndex = 0;
      }
      notifyListeners();
    }
  }

  StoryRoleTemplate? get currentTargetRole {
    if (storyRoles.isEmpty) return null;
    final idx = targetSlotIndex.clamp(0, storyRoles.length - 1);
    return storyRoles[idx];
  }

  StoryRoleTemplate? get heroRole {
    if (storyRoles.isEmpty) return null;
    final found = storyRoles
        .cast<StoryRoleTemplate?>()
        .firstWhere((r) => r?.storyRoleType == StoryRoleType.mainCharacter, orElse: () => null);
    return found ?? storyRoles.first;
  }

  StoryRoleTemplate? get companionRole {
    if (storyRoles.length < 2) return null;
    final found = storyRoles
        .cast<StoryRoleTemplate?>()
        .firstWhere((r) => r?.storyRoleType == StoryRoleType.companion, orElse: () => null);
    return found ?? storyRoles[1];
  }

  /// Tra ve ban nho duoc gan cho vai dien nay. Neu tra ve null tuc la dang lay mac dinh cua CM.
  KidCharacter? getAssignedCharacterForRole(
    AppState state,
    StoryRoleTemplate role,
    int index,
  ) {
    final mapped = state.getMappedCharacterForRole(state.currentStory.id, role.id);
    if (mapped != null && mapped.isParentApproved) return mapped;

    if (index == 0 && state.heroCharacter != null && state.heroCharacter!.isParentApproved) {
      return state.heroCharacter;
    }
    if (index == 1 && state.companionCharacter != null && state.companionCharacter!.isParentApproved) {
      return state.companionCharacter;
    }

    return null;
  }

  /// Kiem tra ban nho nay co dang dong vai nao trong truyen nay khong
  StoryRoleTemplate? getAssignedRoleForCharacter(
    AppState state,
    String characterId,
  ) {
    for (var i = 0; i < storyRoles.length; i++) {
      final r = storyRoles[i];
      final assigned = getAssignedCharacterForRole(state, r, i);
      if (assigned != null && assigned.id == characterId) {
        return r;
      }
    }
    return null;
  }

  /// Gan ban nho vao vai dang chon
  Future<void> assignCharacterToTargetSlot({
    required BuildContext context,
    required AppState state,
    required KidCharacter character,
  }) async {
    if (!character.isParentApproved) {
      RoleUnapprovedWarningDialog.show(context, character.name);
      return;
    }

    if (storyRoles.isEmpty) return;

    final effectiveIndex = targetSlotIndex.clamp(0, storyRoles.length - 1);
    final targetRole = storyRoles[effectiveIndex];

    // Neu ban nho nay da duoc gan cho vai khac trong truyen, go vai cu de tro ve mac dinh cua CM
    for (var i = 0; i < storyRoles.length; i++) {
      if (i != effectiveIndex) {
        final otherRole = storyRoles[i];
        final otherAssigned = getAssignedCharacterForRole(state, otherRole, i);
        if (otherAssigned != null && otherAssigned.id == character.id) {
          state.clearRoleMapping(state.currentStory.id, otherRole.id);
          if (i == 0) state.assignHeroCharacter(null);
          if (i == 1) state.assignCompanionCharacter(null);
        }
      }
    }

    // Gan vao vai hien tai
    await state.assignCharacterRole(
      storyId: state.currentStory.id,
      storyRoleTemplateId: targetRole.id,
      characterId: character.id,
    );

    if (effectiveIndex == 0) {
      state.assignHeroCharacter(character);
    } else if (effectiveIndex == 1) {
      state.assignCompanionCharacter(character);
    }

    // Tu dong chuyen sang vai tiep theo chua duoc gan nhan vat (neu con vai chua gan)
    for (var i = 0; i < storyRoles.length; i++) {
      final r = storyRoles[i];
      final char = getAssignedCharacterForRole(state, r, i);
      if (char == null) {
        targetSlotIndex = i;
        break;
      }
    }

    notifyListeners();
  }

  /// Tra vai dien ve mac dinh cua CM
  void resetRoleToDefault({
    required AppState state,
    required StoryRoleTemplate role,
    required int index,
  }) {
    state.clearRoleMapping(state.currentStory.id, role.id);
    if (index == 0) {
      state.assignHeroCharacter(null);
    } else if (index == 1) {
      state.assignCompanionCharacter(null);
    }
    notifyListeners();
  }

  void startStory(BuildContext context, AppState state) {
    for (var i = 0; i < storyRoles.length; i++) {
      final role = storyRoles[i];
      final assigned = getAssignedCharacterForRole(state, role, i);
      if (assigned != null) {
        if (!assigned.isParentApproved) {
          RoleUnapprovedWarningDialog.show(context, assigned.name);
          return;
        }
        state.assignCharacterRole(
          storyId: state.currentStory.id,
          storyRoleTemplateId: role.id,
          characterId: assigned.id,
        );
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryPlayerScreen(
          appState: state,
          story: state.currentStory,
        ),
      ),
    );
  }
}
