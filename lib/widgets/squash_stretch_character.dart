import 'dart:math';

import 'package:flutter/material.dart';

import 'app_loading.dart';

/// Chế độ hoạt họa để người dùng so sánh và cân nhắc
enum AnimationMode {
  /// Hướng 1: State Machine Đa Chiêu Thức & Xoay 3D (3D Perspective Flip)
  stateMachine3D,

  /// Hướng 2: Mô phỏng Spine / Rive 2D (Uốn Dẻo Dạng Lưới Mesh & Quán Tính Vật Lý Jelly)
  spineJellyMesh,
}

/// Các hành động phức tạp của nhân vật
enum CharacterAction {
  idle, // Nhún thở êm đềm
  patrol, // Tự động đi tuần tra qua lại màn hình + lật người 3D
  dance, // Nhảy Disco 3D xoay vòng tròn 360 độ
  fly, // Bay lượn bồng bềnh hình sin trên không
  stomp, // Nhảy đại địa chấn rung rinh màn hình
  sleep, // Nằm ngủ ngáy Zzz
}

/// Interactive Multi-State Character Animator
/// Hỗ trợ cả 2 hướng tiếp cận để xem thử và so sánh trực tiếp
class SquashStretchCharacter extends StatefulWidget {
  final String imagePath;
  final String characterName;
  final String? initialPhrase;
  final double size;
  final bool enableDrag;
  final Offset? initialOffset;
  final AnimationMode mode;
  final CharacterAction currentAction;
  final bool flipHorizontal;
  final double scale;
  final VoidCallback? onScreenShake;
  final ValueChanged<Offset>? onPositionChanged;
  final ValueChanged<Offset>? onDragEndPosition;
  final ValueChanged<CharacterAction>? onActionChanged;

  const SquashStretchCharacter({
    super.key,
    required this.imagePath,
    this.characterName = 'Bạn Đồng Hành',
    this.initialPhrase,
    this.size = 110.0,
    this.enableDrag = true,
    this.initialOffset,
    this.mode = AnimationMode.stateMachine3D,
    this.currentAction = CharacterAction.idle,
    this.flipHorizontal = false,
    this.scale = 1.0,
    this.onScreenShake,
    this.onPositionChanged,
    this.onDragEndPosition,
    this.onActionChanged,
  });

  @override
  State<SquashStretchCharacter> createState() => _SquashStretchCharacterState();
}

class _SquashStretchCharacterState extends State<SquashStretchCharacter>
    with TickerProviderStateMixin {
  // 1. Idle Bobbing & Breathing Controller
  late AnimationController _idleController;

  // 2. Tap to Jump Controller
  late AnimationController _jumpController;
  late Animation<double> _jumpAnimation;

  // 3. Patrol / Auto-walk Controller (Đi tuần tra qua lại)
  late AnimationController _patrolController;
  bool _facingRight = true;
  double _flipAngle = 0.0; // 0.0 -> pi (xoay 3D lật hướng)

  // 4. Disco Dance Controller (Xoay 3D 360 độ + rung nhịp)
  late AnimationController _danceController;

  // 5. Flight Controller (Lượn sóng hình sin)
  late AnimationController _flyController;

  // 6. Super Stomp Controller (Nhảy đại địa chấn)
  late AnimationController _stompController;

  // 7. Jelly Mesh Physics Controller (Hướng 2 - Spine/Rive)
  late AnimationController _jellyMeshController;

  // Drag position
  late Offset _position;
  bool _isDragging = false;
  Offset _dragVelocity = Offset.zero;

  // Speech bubble
  bool _showSpeechBubble = false;
  String _currentSpeech = '';
  int _speechIndex = 0;

  final List<String> _defaultQuotes = [
    'Chào bé yêu!',
    'Cùng tớ khám phá thế giới nhé!',
    'Câu chuyện này ly kỳ quá!',
    'Kéo tớ đi thám hiểm với bé ơi!',
    'Bé vẽ và sáng tạo thật tuyệt vời!',
  ];

  @override
  void initState() {
    super.initState();
    _position = widget.initialOffset ?? const Offset(25, 95);
    _currentSpeech = widget.initialPhrase ?? _defaultQuotes[0];

    // 1. Idle Controller (Nhún thở nhẹ nhàng)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    // 2. Jump Controller
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _jumpAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: -45.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -45.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 55,
      ),
    ]).animate(_jumpController);

    // 3. Patrol Auto-walk Controller (Đi dạo qua lại)
    _patrolController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 4500),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() {
              _facingRight = false;
              _flipAngle = pi;
            });
            _patrolController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            setState(() {
              _facingRight = true;
              _flipAngle = 0.0;
            });
            _patrolController.forward();
          }
        });

    // 4. Disco Dance Controller (Xoay 360 độ trục Y)
    _danceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    // 5. Flight Controller (Lượn hình sin trên trời)
    _flyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // 6. Super Stomp Controller (Nhảy đại địa chấn)
    _stompController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _stompController.addListener(() {
      // Khi vừa chạm đất ở mốc 0.65 thời gian -> rung màn hình!
      if (_stompController.value >= 0.62 && _stompController.value <= 0.68) {
        widget.onScreenShake?.call();
      }
    });

    // 7. Jelly Mesh Physics Controller (Hướng 2 - Spine/Rive)
    _jellyMeshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _syncAction(widget.currentAction);

    // Show initial greeting briefly
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _showSpeechBubble = true);
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _showSpeechBubble = false);
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant SquashStretchCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentAction != widget.currentAction) {
      _syncAction(widget.currentAction);
    }
    if (widget.initialOffset != null &&
        oldWidget.initialOffset != widget.initialOffset) {
      setState(() {
        _position = widget.initialOffset!;
      });
    }
    if (widget.initialPhrase != null &&
        oldWidget.initialPhrase != widget.initialPhrase) {
      setState(() {
        _currentSpeech = widget.initialPhrase!;
        _showSpeechBubble = true;
      });
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showSpeechBubble = false);
      });
    }
  }

  void _syncAction(CharacterAction action) {
    // Reset other action loops
    _patrolController.stop();
    _danceController.stop();
    _flyController.stop();
    _stompController.stop();

    switch (action) {
      case CharacterAction.idle:
        break;
      case CharacterAction.patrol:
        _patrolController.forward(from: _patrolController.value);
        break;
      case CharacterAction.dance:
        _danceController.repeat();
        break;
      case CharacterAction.fly:
        _flyController.repeat();
        break;
      case CharacterAction.stomp:
        _stompController.forward(from: 0.0);
        break;
      case CharacterAction.sleep:
        break;
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _jumpController.dispose();
    _patrolController.dispose();
    _danceController.dispose();
    _flyController.dispose();
    _stompController.dispose();
    _jellyMeshController.dispose();
    super.dispose();
  }

  void _onTapCharacter() {
    _jumpController.forward(from: 0.0);

    setState(() {
      _speechIndex = (_speechIndex + 1) % _defaultQuotes.length;
      _currentSpeech = _defaultQuotes[_speechIndex];
      _showSpeechBubble = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showSpeechBubble = false);
    });
  }

  Widget _buildCharacterImage() {
    final path = widget.imagePath;
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _fallbackIcon(),
      );
    } else {
      return Image.network(
        path,
        fit: BoxFit.contain,
        loadingBuilder: appImageLoadingBuilder,
        errorBuilder: (_, _, _) => _fallbackIcon(),
      );
    }
  }

  Widget _fallbackIcon() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDE047),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.face_retouching_natural_rounded,
          size: 40,
          color: Color(0xFFB45309),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _idleController,
        _jumpController,
        _patrolController,
        _danceController,
        _flyController,
        _stompController,
        _jellyMeshController,
      ]),
      builder: (context, _) {
        // Tọa độ và hiệu ứng theo từng hành động
        double posX = _position.dx;
        double posY = _position.dy;
        double scaleX = 1.0 * widget.scale;
        double scaleY = 1.0 * widget.scale;
        double tilt = 0.0;
        double rotY = (widget.flipHorizontal ? pi : 0.0) + _flipAngle;
        double shadowScale = 1.0 * widget.scale;
        double shadowOpacity = 0.25;

        final tIdle = _idleController.value;

        // ==========================================
        // HƯỚNG 1: STATE MACHINE 5 CHIÊU THỨC & 3D
        // ==========================================
        if (widget.mode == AnimationMode.stateMachine3D) {
          switch (widget.currentAction) {
            case CharacterAction.idle:
              // Nhún thở êm đềm
              scaleX = (1.0 + (tIdle - 0.5) * 0.12) * widget.scale;
              scaleY = (1.0 - (tIdle - 0.5) * 0.12) * widget.scale;
              tilt = _isDragging ? 0.12 : sin(tIdle * pi) * 0.05;
              posY += (1.0 - tIdle) * 8.0;
              shadowScale = (1.0 + (tIdle - 0.5) * 0.25) * widget.scale;
              shadowOpacity = 0.28 - tIdle * 0.1;
              break;

            case CharacterAction.patrol:
              // Tự động đi tuần tra qua lại màn hình
              final p = _patrolController.value;
              posX = _position.dx + (p - 0.5) * 160.0;
              // Bước đi dập dồn
              final stepTilt = sin(p * 28 * pi) * 0.14;
              final stepHop = (sin(p * 28 * pi)).abs() * 12.0;
              tilt = stepTilt;
              posY = _position.dy - stepHop;
              scaleX = 1.05 * widget.scale;
              scaleY = (0.96 + stepHop * 0.01) * widget.scale;
              final faceAngle = _facingRight ? 0.0 : pi;
              rotY = (widget.flipHorizontal ? pi : 0.0) + faceAngle;
              shadowScale = (0.8 + stepHop * 0.02) * widget.scale;
              break;

            case CharacterAction.dance:
              // Nhảy Disco 3D xoay vòng 360 độ
              final d = _danceController.value;
              rotY = (widget.flipHorizontal ? pi : 0.0) + d * 2 * pi;
              final danceHop = sin(d * 4 * pi).abs() * 25.0;
              posY = _position.dy - danceHop;
              tilt = sin(d * 6 * pi) * 0.18;
              scaleX = (1.0 + sin(d * 4 * pi) * 0.2) * widget.scale;
              scaleY = (1.0 - sin(d * 4 * pi) * 0.2) * widget.scale;
              shadowScale = (0.6 + danceHop * 0.02) * widget.scale;
              break;

            case CharacterAction.fly:
              // Bay lượn sóng hình sin bồng bềnh trên bầu trời
              final f = _flyController.value;
              posX = _position.dx + sin(f * 2 * pi) * 70.0;
              posY = (_position.dy - 35.0) + sin(f * 4 * pi) * 18.0;
              tilt = cos(f * 2 * pi) * 0.15;
              scaleX = 1.02 * widget.scale;
              scaleY = 1.02 * widget.scale;
              shadowScale = 0.45 * widget.scale;
              shadowOpacity = 0.08;
              break;

            case CharacterAction.stomp:
              // Cú nhảy đại địa chấn: Nhún lấy đà -> vút lên -> đập đất rung rinh
              final s = _stompController.value;
              if (s < 0.25) {
                // Nhún nén lấy đà
                scaleX = 1.25 * widget.scale;
                scaleY = 0.72 * widget.scale;
                posY = _position.dy + 10.0;
              } else if (s < 0.65) {
                // Bật vút lên mây
                final rocketT = (s - 0.25) / 0.4;
                final jumpHeight = sin(rocketT * pi) * 85.0;
                posY = _position.dy - jumpHeight;
                scaleX = 0.85 * widget.scale;
                scaleY = 1.25 * widget.scale;
                shadowScale = 0.4 * widget.scale;
              } else {
                // Tiếp đất chấn động & hồi phục
                final landT = (s - 0.65) / 0.35;
                scaleX = (1.3 - landT * 0.3) * widget.scale;
                scaleY = (0.68 + landT * 0.32) * widget.scale;
                posY = _position.dy;
              }
              break;

            case CharacterAction.sleep:
              // Nằm ngủ ngáy Zzz
              tilt = widget.flipHorizontal ? 0.45 : -0.45;
              scaleX = (1.0 + (tIdle - 0.5) * 0.05) * widget.scale;
              scaleY = (0.95 - (tIdle - 0.5) * 0.05) * widget.scale;
              posY = _position.dy + 14.0;
              break;
          }
        }
        // ==========================================
        // HƯỚNG 2: MÔ PHỎNG RIVE / SPINE 2D JELLY MESH
        // ==========================================
        else {
          // Uốn dẻo dạng lưới mềm (Jelly Mesh Deformation)
          final j = _jellyMeshController.value;
          // Quán tính đàn hồi theo vận tốc kéo (Shear / Skew)
          final inertiaSkew = _isDragging
              ? (_dragVelocity.dx * 0.008).clamp(-0.25, 0.25)
              : 0.0;
          final jellySin = sin(j * 2 * pi);

          // Biến dạng co bóp mềm mại như thạch (Jelly physics)
          scaleX =
              (1.0 + jellySin * 0.14 - inertiaSkew.abs() * 0.2) * widget.scale;
          scaleY = (1.0 - jellySin * 0.14) * widget.scale;
          tilt = inertiaSkew + sin(j * pi) * 0.08;
          posY += (1.0 - j) * 10.0;
          shadowScale = (1.0 + jellySin * 0.2) * widget.scale;
        }

        // Tap Jump Overlap
        if (_jumpController.isAnimating) {
          final jumpY = _jumpAnimation.value;
          posY += jumpY;
          scaleX = (jumpY < -20 ? 0.88 : 1.15) * widget.scale;
          scaleY = (jumpY < -20 ? 1.16 : 0.88) * widget.scale;
        }

        return Positioned(
          left: posX,
          top: posY,
          child: GestureDetector(
            onPanStart: widget.enableDrag
                ? (details) => setState(() => _isDragging = true)
                : null,
            onPanUpdate: widget.enableDrag
                ? (details) {
                    setState(() {
                      _dragVelocity = details.delta;
                      _position += details.delta;
                      _position = Offset(
                        _position.dx.clamp(-20.0, 320.0),
                        _position.dy.clamp(0.0, 240.0),
                      );
                    });
                    widget.onPositionChanged?.call(_position);
                  }
                : null,
            onPanEnd: widget.enableDrag
                ? (details) {
                    setState(() {
                      _isDragging = false;
                      _dragVelocity = Offset.zero;
                    });
                    widget.onDragEndPosition?.call(_position);
                  }
                : null,
            onTap: _onTapCharacter,
            child: SizedBox(
              width: widget.size + 40,
              height: widget.size + 70,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // 1. Soft Dynamic Shadow on Ground
                  Positioned(
                    bottom: 6,
                    child: Transform.scale(
                      scaleX: shadowScale,
                      scaleY: 0.5,
                      child: Container(
                        width: widget.size * 0.7,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: shadowOpacity),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),

                  // 2. Character Body with 3D Perspective Flip / Spine Mesh Deformation
                  Positioned(
                    bottom: 12,
                    child: Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002) // 3D Perspective depth
                        ..rotateY(rotY),
                      child: Transform.rotate(
                        angle: tilt,
                        alignment: Alignment.bottomCenter,
                        child: Transform.scale(
                          scaleX: scaleX,
                          scaleY: scaleY,
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            width: widget.size,
                            height: widget.size,
                            child: _buildCharacterImage(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Particle Overlays (Theo từng chiêu thức)
                  if (widget.currentAction == CharacterAction.dance)
                    Positioned(
                      top: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.music_note_rounded, size: 16, color: Color(0xFF8B5CF6)),
                          SizedBox(width: 28),
                          Icon(Icons.music_note_rounded, size: 18, color: Color(0xFFEC4899)),
                        ],
                      ),
                    ),

                  if (widget.currentAction == CharacterAction.fly)
                    Positioned(
                      top: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFFF59E0B)),
                          SizedBox(width: 32),
                          Icon(Icons.star_rounded, size: 16, color: Color(0xFFFBBF24)),
                        ],
                      ),
                    ),

                  if (widget.currentAction == CharacterAction.sleep)
                    Positioned(
                      top: 2,
                      right: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Zzz...',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),

                  // 4. Speech Bubble on Tap
                  if (_showSpeechBubble)
                    Positioned(
                      top: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        constraints: const BoxConstraints(maxWidth: 160),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFF472B6),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _currentSpeech,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF831843),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  // 5. Drag indicator
                  if (_isDragging)
                    Positioned(
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4899),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Đang dạo chơi...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
