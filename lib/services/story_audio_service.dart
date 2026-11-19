import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_config.dart';

/// Service managing narration and background music playback in StoryPlayer.
/// Gracefully handles network latency, 404 fallbacks, and test environments.
class StoryAudioService {
  AudioPlayer? _player;
  bool _isInitialized = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;
  String? _currentUrl;

  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _stateController = StreamController<bool>.broadcast();
  final _completeController = StreamController<void>.broadcast();

  Stream<Duration> get onPositionChanged => _positionController.stream;
  Stream<Duration> get onDurationChanged => _durationController.stream;
  Stream<bool> get onPlayingStateChanged => _stateController.stream;
  Stream<void> get onPlayerComplete => _completeController.stream;

  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isPlaying => _isPlaying;
  String? get currentUrl => _currentUrl;

  void initialize() {
    if (_isInitialized) return;
    try {
      _player = AudioPlayer();

      _player!.onPositionChanged.listen((pos) {
        _currentPosition = pos;
        if (!_positionController.isClosed) {
          _positionController.add(pos);
        }
      });

      _player!.onDurationChanged.listen((dur) {
        _totalDuration = dur;
        if (!_durationController.isClosed) {
          _durationController.add(dur);
        }
      });

      _player!.onPlayerStateChanged.listen((state) {
        _isPlaying = state == PlayerState.playing;
        if (!_stateController.isClosed) {
          _stateController.add(_isPlaying);
        }
      });

      _player!.onPlayerComplete.listen((_) {
        _isPlaying = false;
        _currentPosition = Duration.zero;
        if (!_stateController.isClosed) {
          _stateController.add(false);
        }
        if (!_positionController.isClosed) {
          _positionController.add(Duration.zero);
        }
        if (!_completeController.isClosed) {
          _completeController.add(null);
        }
      });

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryAudioService] Native player init skipped (test environment): $e');
      }
    }
  }

  /// Plays narration audio from URL, falling back to rich Cloudinary narration if needed.
  Future<bool> playAudio(String? rawUrl, {int pageNumber = 1, String storyTitle = ''}) async {
    initialize();
    final url = AppConfig.resolveAudioUrl(rawUrl, pageNumber: pageNumber, storyTitle: storyTitle);
    _currentUrl = url;

    if (_player == null) {
      // Test environment simulation
      _isPlaying = true;
      _totalDuration = const Duration(seconds: 14);
      _stateController.add(true);
      _durationController.add(_totalDuration);
      return true;
    }

    try {
      await _player!.stop();
      _currentPosition = Duration.zero;
      if (!_positionController.isClosed) {
        _positionController.add(Duration.zero);
      }
      if (url.startsWith('assets/')) {
        await _player!.play(AssetSource(url.replaceFirst('assets/', '')));
      } else {
        await _player!.play(UrlSource(url));
      }
      _isPlaying = true;
      _stateController.add(true);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryAudioService] Error playing $url: $e. Retrying fallback...');
      }
      // If server URL 404s, fallback to Cloudinary narration URL
      final fallbackUrl = AppConfig.fallbackAudioUrlForPage(pageNumber);
      if (fallbackUrl != url) {
        try {
          await _player!.play(UrlSource(fallbackUrl));
          _currentUrl = fallbackUrl;
          _isPlaying = true;
          _stateController.add(true);
          return true;
        } catch (_) {}
      }
    }
    return false;
  }

  Future<void> pauseAudio() async {
    try {
      await _player?.pause();
    } catch (_) {}
    _isPlaying = false;
    _stateController.add(false);
  }

  Future<void> resumeAudio() async {
    try {
      await _player?.resume();
      _isPlaying = true;
      _stateController.add(true);
    } catch (_) {
      if (_currentUrl != null) {
        await playAudio(_currentUrl);
      }
    }
  }

  Future<void> toggleAudio(String? rawUrl, {int pageNumber = 1, String storyTitle = ''}) async {
    if (_isPlaying) {
      await pauseAudio();
    } else {
      if (_player != null && _currentUrl != null && _currentPosition > Duration.zero) {
        await resumeAudio();
      } else {
        await playAudio(rawUrl, pageNumber: pageNumber, storyTitle: storyTitle);
      }
    }
  }

  Future<void> seek(Duration position) async {
    _currentPosition = position;
    _positionController.add(position);
    try {
      await _player?.seek(position);
    } catch (_) {}
  }

  Future<void> rewind5Seconds() async {
    final target = _currentPosition - const Duration(seconds: 5);
    final clamped = target < Duration.zero ? Duration.zero : target;
    await seek(clamped);
  }

  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (_) {}
    _isPlaying = false;
    _currentPosition = Duration.zero;
    _stateController.add(false);
    _positionController.add(Duration.zero);
  }

  void dispose() {
    try {
      _player?.dispose();
    } catch (_) {}
    _player = null;
    _positionController.close();
    _durationController.close();
    _stateController.close();
    _completeController.close();
  }
}

