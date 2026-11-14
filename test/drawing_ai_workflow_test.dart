import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sketch_table/models/models.dart';
import 'package:sketch_table/services/drawing_ai_service.dart';
import 'package:sketch_table/state/app_state.dart';
import 'package:sketch_table/utils/app_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('2-Stage AI Character Creation Models Tests', () {
    test('AiAllowedCharTypeDto parses from backend JSON correctly', () {
      final json = {
        'id': 'a1b2c3d4-1111-2222-3333-444455556666',
        'nameEn': 'dragon',
        'name': 'Hiệp Sĩ Rồng Con',
        'description': 'Chú rồng con tinh nghịch',
        'status': 'Active',
      };

      final dto = AiAllowedCharTypeDto.fromJson(json);
      expect(dto.id, equals('a1b2c3d4-1111-2222-3333-444455556666'));
      expect(dto.nameEn, equals('dragon'));
      expect(dto.displayName, equals('Hiệp Sĩ Rồng Con'));
      expect(dto.emoji, equals('🐲'));
    });

    test('AnalyzeDrawingResponse deserialization matches Giai đoạn 1 contract', () {
      final json = {
        'drawingId': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'originalImageUrl': 'https://res.cloudinary.com/drawings/sketch_01.png',
        'drawingType': 'Canvas',
        'isRecognized': true,
        'suggestedCharTypes': [
          {
            'id': 'a1b2c3d4-1111-2222-3333-444455556666',
            'nameEn': 'cat',
            'name': 'mèo',
            'description': 'Kiểu nhân vật mèo',
            'status': 'Active',
          },
          {
            'id': 'b2c3d4e5-1111-2222-3333-444455556666',
            'nameEn': 'tiger',
            'name': 'hổ',
            'description': 'Kiểu nhân vật hổ',
            'status': 'Active',
          }
        ],
        'detectedTags': ['orange fur', 'striped tail', 'smiling face'],
        'standardizedPrompt': 'A cute 2D children\'s storybook illustration of a friendly orange cat',
        'remainingParentCredits': 3660,
        'remainingDailyCharacterLimit': 4,
      };

      final response = AnalyzeDrawingResponse.fromJson(json);
      expect(response.drawingId, equals('3fa85f64-5717-4562-b3fc-2c963f66afa6'));
      expect(response.isRecognized, isTrue);
      expect(response.suggestedCharTypes.length, equals(2));
      expect(response.suggestedCharTypes[0].emoji, equals('🐱'));
      expect(response.detectedTags, contains('orange fur'));
      expect(response.remainingParentCredits, equals(3660));
      expect(response.remainingDailyCharacterLimit, equals(4));
    });

    test('GenerateCharacterRequest serialization matches Giai đoạn 2 contract', () {
      const request = GenerateCharacterRequest(
        drawingId: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        charTypeId: 'a1b2c3d4-1111-2222-3333-444455556666',
        standardizedPrompt: 'Cute cat prompt',
        childAdditionalIdea: 'Mặc áo choàng đỏ',
        detectedTags: ['orange', 'happy'],
        isRegenerate: false,
      );

      final json = request.toJson();
      expect(json['drawingId'], equals('3fa85f64-5717-4562-b3fc-2c963f66afa6'));
      expect(json['charTypeId'], equals('a1b2c3d4-1111-2222-3333-444455556666'));
      expect(json['childAdditionalIdea'], equals('Mặc áo choàng đỏ'));
      expect(json['isRegenerate'], isFalse);
    });

    test('GenerateCharacterResponse deserialization matches Giai đoạn 2 contract', () {
      final json = {
        'aiCharacterGenerateId': '9c8b7a65-4321-4562-b3fc-2c963f66afa6',
        'characterId': '7d6e5f43-1234-4562-b3fc-2c963f66afa6',
        'drawingId': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'charTypeId': 'a1b2c3d4-1111-2222-3333-444455556666',
        'generateImageUrl': 'https://res.cloudinary.com/characters/char_a1b2c3.png',
        'aiPromptUsed': 'A cute 2D cat...',
        'aiGenStatus': 'Success',
        'characterStatus': 'Preview',
        'remainingParentCredits': 3510,
        'remainingDailyCharacterLimit': 3,
      };

      final response = GenerateCharacterResponse.fromJson(json);
      expect(response.characterId, equals('7d6e5f43-1234-4562-b3fc-2c963f66afa6'));
      expect(response.characterStatus, equals('Preview'));
      expect(response.remainingParentCredits, equals(3510));
      expect(response.remainingDailyCharacterLimit, equals(3));
    });

    test('CreditTransactionLog parses accurately', () {
      final json = {
        'id': 'log-001',
        'parentProfileId': 'parent-123',
        'actionType': 'Spend',
        'featureKey': 'CharacterGeneration',
        'amount': 150,
        'creditBefore': 3660,
        'creditAfter': 3510,
        'description': 'Tạo ảnh nhân vật con mèo lần đầu',
        'createdAt': '2026-11-09T22:00:00Z',
      };

      final log = CreditTransactionLog.fromJson(json);
      expect(log.amount, equals(150));
      expect(log.creditBefore, equals(3660));
      expect(log.creditAfter, equals(3510));
      expect(log.actionType, equals('Spend'));
    });
  });

  group('DrawingAiService Endpoints & Fallback Resilience Tests', () {
    test('AppConfig exposes valid backend URLs for 2-stage workflow', () {
      expect(AppConfig.drawingsAnalyzeUrl, contains('/api/drawings/analyze'));
      expect(AppConfig.drawingsGenerateCharacterUrl, contains('/api/drawings/generate-character'));
      expect(AppConfig.creditTransactionLogsUrl, contains('/api/credit-transaction-logs'));
      expect(
        AppConfig.creditTransactionLogsByParentUrl('parent-123'),
        contains('/api/credit-transaction-logs/parent-profile/parent-123'),
      );
    });

    test('DrawingAiService handles offline resilience for analyzeDrawing', () async {
      final fakeBytes = utf8.encode('fake-png-bytes');
      final result = await DrawingAiService.analyzeDrawing(
        bytes: fakeBytes,
        drawingType: 0,
        token: 'fake-token',
      );

      // Even if network fails or mock backend returns, result is resilient and not null
      expect(result.data, isNotNull);
      expect(result.data!.drawingId.isNotEmpty, isTrue);
      expect(result.data!.suggestedCharTypes.isNotEmpty, isTrue);
    });

    test('DrawingAiService handles offline resilience for generateCharacter', () async {
      const request = GenerateCharacterRequest(
        drawingId: 'drawing-123',
        charTypeId: 'type-123',
        isRegenerate: false,
      );

      final result = await DrawingAiService.generateCharacter(
        request: request,
        token: 'fake-token',
      );

      expect(result.data, isNotNull);
      expect(result.data!.generateImageUrl.isNotEmpty, isTrue);
      expect(result.data!.aiGenStatus, equals('Success'));
    });

    test('DrawingAiService fetchCreditTransactionLogs returns logs', () async {
      final logs = await DrawingAiService.fetchCreditTransactionLogs(
        parentProfileId: 'mock-parent-id',
      );
      expect(logs.isNotEmpty, isTrue);
      expect(logs.first.amount, greaterThan(0));
    });
  });

  group('AppState Workflow 3 Limits & Credit Logic Tests', () {
    test('AppState initial credit conditions and affordability gates', () {
      final appState = AppState();
      expect(appState.parentCredits, equals(3690));
      expect(appState.canAffordAnalyze, isTrue);
      expect(appState.canAffordGenerate, isTrue);
      expect(appState.canAffordRegenerate, isTrue);
      expect(appState.canAffordFullCreation, isTrue);
      expect(appState.canCreateCharacter, isTrue);
    });

    test('AppState updateCreditsAndLimits properly synchronizes balance & attempts', () {
      final appState = AppState();
      appState.updateCreditsAndLimits(remainingCredits: 3540, remainingLimit: 2);
      expect(appState.parentCredits, equals(3540));
      expect(appState.remainingCharacterLimit, equals(2));
    });

    test('AppState restoreCharacterCreationAttempt restores 1 daily attempt upon cancel', () {
      final appState = AppState();
      final before = appState.remainingCharacterLimit;
      appState.useCharacterCreationAttempt();
      expect(appState.remainingCharacterLimit, equals(before - 1));

      appState.restoreCharacterCreationAttempt();
      expect(appState.remainingCharacterLimit, equals(before));
    });

    test('AppState addNewCharacter assigns character and adds to list', () {
      final appState = AppState();
      final initialCount = appState.characters.length;

      final newChar = KidCharacter(
        id: 'new_char_01',
        name: 'Bạn Khủng Long Xanh',
        title: 'Nhân vật sáng tạo của bé',
        description: 'Mascot 3D sinh từ nét vẽ',
        drawingUrl: 'https://example.com/draw.png',
        avatar3dUrl: 'https://example.com/mascot.png',
        personality: 'Dũng Sĩ',
        assignedRole: 'Dũng Sĩ',
        isParentApproved: false,
        voicePhrase: 'Chào bé yêu!',
        themeColor: const Color(0xFFF59E0B),
        createdAt: DateTime.now(),
      );

      appState.addNewCharacter(newChar);
      expect(appState.characters.length, equals(initialCount + 1));
      expect(appState.characters.first.name, equals('Bạn Khủng Long Xanh'));
      expect(appState.heroCharacter?.name, equals('Bạn Khủng Long Xanh'));
    });
  });
}
