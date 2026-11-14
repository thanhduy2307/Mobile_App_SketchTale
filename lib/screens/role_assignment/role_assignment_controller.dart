import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/story_service.dart';
import '../../state/app_state.dart';
import '../story_player/story_player_screen.dart';
import 'dialogs/role_unapproved_warning_dialog.dart';

/// 🧠 Controller Quản Lý Gán Vai Trong Truyện (RoleAssignmentController)
class RoleAssignmentController extends ChangeNotifier {
  int targetSlot = 1; // 1: Hero, 2: Companion
  List<StoryRoleTemplate> storyRoles = [];
  bool isLoadingRoles = false;

  void setTargetSlot(int slot) {
    if (targetSlot == slot) return;
    targetSlot = slot;
    notifyListeners();
  }

  Future<void> loadStoryRoles({required String storyId, String? token}) async {
    isLoadingRoles = true;
    notifyListeners();
    try {
      final roles = await StoryService.fetchStoryRoles(storyId, token: token);
      if (roles.isNotEmpty) {
        storyRoles = roles;
      }
    } catch (e) {
      debugPrint('[RoleAssignmentController] Error loading roles: $e');
    } finally {
      isLoadingRoles = false;
      notifyListeners();
    }
  }

  StoryRoleTemplate? get heroRole => storyRoles
      .cast<StoryRoleTemplate?>()
      .firstWhere((r) => r?.storyRoleType == StoryRoleType.mainCharacter, orElse: () => null);

  StoryRoleTemplate? get companionRole => storyRoles
      .cast<StoryRoleTemplate?>()
      .firstWhere((r) => r?.storyRoleType == StoryRoleType.companion, orElse: () => null);

  void assignCharacterToTargetSlot({
    required BuildContext context,
    required AppState state,
    required KidCharacter character,
  }) {
    if (!character.isParentApproved) {
      RoleUnapprovedWarningDialog.show(context, character.name);
      return;
    }

    if (targetSlot == 1) {
      state.assignHeroCharacter(character);
      if (state.companionCharacter?.id == character.id) {
        state.assignCompanionCharacter(null);
      }
      targetSlot = 2; // Auto-advance to next slot
    } else {
      state.assignCompanionCharacter(character);
      if (state.heroCharacter?.id == character.id) {
        state.assignHeroCharacter(null);
      }
    }
    notifyListeners();
  }

  void startStory(BuildContext context, AppState state) {
    final hero = state.heroCharacter;
    final hRole = heroRole;
    final companion = state.companionCharacter;
    final cRole = companionRole;

    if (hero != null) {
      if (!hero.isParentApproved) {
        RoleUnapprovedWarningDialog.show(context, hero.name);
        return;
      }
      if (hRole != null) {
        state.assignCharacterRole(
          storyId: state.currentStory.id,
          storyRoleTemplateId: hRole.id,
          characterId: hero.id,
        );
      }
    }

    if (companion != null) {
      if (!companion.isParentApproved) {
        RoleUnapprovedWarningDialog.show(context, companion.name);
        return;
      }
      if (cRole != null) {
        state.assignCharacterRole(
          storyId: state.currentStory.id,
          storyRoleTemplateId: cRole.id,
          characterId: companion.id,
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

