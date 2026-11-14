import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sketch_table/models/models.dart';
import 'package:sketch_table/state/app_state.dart';
import 'package:sketch_table/utils/app_config.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthController Tests based on AUTH_CONTROLLER_README.md v2.2', () {
    test('AuthTokenData serialization & deserialization (Child & Parent)', () {
      final childJson = {
        'token': 'jwt-access-token-12345',
        'refreshToken': 'refresh-token-rot-67890',
        'username': 'be_bin',
        'email': null,
        'role': 'Child',
      };

      final authData = AuthTokenData.fromJson(childJson);
      expect(authData.token, 'jwt-access-token-12345');
      expect(authData.refreshToken, 'refresh-token-rot-67890');
      expect(authData.username, 'be_bin');
      expect(authData.email, isNull);
      expect(authData.role, 'Child');

      final outJson = authData.toJson();
      expect(outJson['token'], 'jwt-access-token-12345');
      expect(outJson['refreshToken'], 'refresh-token-rot-67890');
      expect(outJson['username'], 'be_bin');
      expect(outJson['role'], 'Child');
    });

    test('UserProfile & ParentProfileInfo parsing matching Section 2.8 specification', () {
      final profileJson = {
        'id': '8c59f2a4-7221-4ba2-921d-91b456ce43d1',
        'username': 'phuhuynh_an',
        'email': 'phuhuynh_an@gmail.com',
        'firstName': 'An',
        'lastName': 'Nguyen',
        'dob': '1990-01-01',
        'gender': 'Male',
        'role': 'Parent',
        'createdAt': '2026-10-20T10:15:30.000Z',
        'parentProfile': {
          'childProfileLimit': 2,
          'remainingChildProfileLimit': 1,
          'monthlyCreditLimit': 500,
          'remainingMonthlyCreditLimit': 350,
          'canExportStory': true,
          'accessFullStories': true,
          'subscriptionTrialPlusPlan': false,
        },
        'childProfile': null,
      };

      final profile = UserProfile.fromJson(profileJson);
      expect(profile.id, '8c59f2a4-7221-4ba2-921d-91b456ce43d1');
      expect(profile.username, 'phuhuynh_an');
      expect(profile.email, 'phuhuynh_an@gmail.com');
      expect(profile.displayName, 'An Nguyen');
      expect(profile.isParent, isTrue);
      expect(profile.isChild, isFalse);
      expect(profile.parentProfile?.childProfileLimit, 2);
      expect(profile.parentProfile?.remainingMonthlyCreditLimit, 350);
      expect(profile.parentProfile?.canExportStory, isTrue);
    });

    test('AppConfig Swagger Auth URLs generation for all 14 endpoints', () {
      final base = AppConfig.baseUrl;

      expect(AppConfig.authRegisterParentUrl, '$base/api/auth/register/parent');
      expect(AppConfig.authRegisterChildUrl, '$base/api/auth/register/child');
      expect(AppConfig.authLoginUrl, '$base/api/auth/login');
      expect(AppConfig.authLoginChildUrl, '$base/api/auth/login/child');
      expect(AppConfig.childLoginUrl, '$base/api/auth/login/child');
      expect(AppConfig.authForgotPasswordUrl, '$base/api/auth/forgot-password');
      expect(AppConfig.authResetPasswordUrl, '$base/api/auth/reset-password');
      expect(AppConfig.authChangePasswordUrl, '$base/api/auth/change-password');
      expect(AppConfig.authProfileUrl, '$base/api/auth/profile');
      expect(AppConfig.authConfirmEmailUrl, '$base/api/auth/confirm-email');
      expect(AppConfig.authResendConfirmationEmailUrl, '$base/api/auth/resend-confirmation-email');
      expect(AppConfig.authLogoutUrl, '$base/api/auth/logout');
      expect(AppConfig.authRefreshTokenUrl, '$base/api/auth/refresh-token');
      expect(AppConfig.authCurrentRoleUrl, '$base/api/auth/current-role');
    });

    test('AppState maintains tokens, roles, and cleans them on logout', () async {
      final appState = AppState();

      // Initial state
      expect(appState.isLoggedIn, isFalse);
      expect(appState.authToken, isNull);
      expect(appState.refreshToken, isNull);

      // Perform login
      appState.login(
        'Bé Bin',
        token: 'access-token-jwt-1',
        refreshToken: 'refresh-token-rot-1',
        username: 'be_bin',
        role: 'Child',
      );

      expect(appState.isLoggedIn, isTrue);
      expect(appState.kidName, 'Bé Bin');
      expect(appState.authToken, 'access-token-jwt-1');
      expect(appState.refreshToken, 'refresh-token-rot-1');
      expect(appState.userRole, 'Child');
      expect(appState.childUsername, 'be_bin');

      // Logout should clear all auth tokens locally (and sends blacklist call to backend)
      await appState.logout();

      expect(appState.isLoggedIn, isFalse);
      expect(appState.authToken, isNull);
      expect(appState.refreshToken, isNull);
      expect(appState.childUsername, isNull);
      expect(appState.userProfile, isNull);
      expect(appState.userRole, 'Child');
    });
  });
}
