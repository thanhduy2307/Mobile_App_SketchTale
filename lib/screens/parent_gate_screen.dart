import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class ParentGateScreen extends StatefulWidget {
  final AppState appState;

  const ParentGateScreen({
    super.key,
    required this.appState,
  });

  @override
  State<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends State<ParentGateScreen> {
  String _enteredPin = '';
  final String _correctAnswer = '12'; // 7 + 5 = 12
  bool _isUnlocked = false;
  String _statusText = 'Nhập kết quả phép tính...';

  void _handleNumberTap(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _checkAnswer();
      });
    }
  }

  void _handleBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _statusText = 'Đã nhập ${_enteredPin.length} ký tự...';
      });
    }
  }

  void _handleClear() {
    setState(() {
      _enteredPin = '';
      _statusText = 'Nhập kết quả phép tính...';
    });
  }

  void _checkAnswer() {
    if (_enteredPin == _correctAnswer) {
      setState(() {
        _isUnlocked = true;
        _statusText = 'Mở khóa thành công! 🎉';
      });
    } else if (_enteredPin.length >= 2) {
      setState(() {
        _statusText = 'Kết quả chưa đúng rồi, thử lại nhé!';
      });
    } else {
      setState(() {
        _statusText = 'Đã nhập ${_enteredPin.length} ký tự...';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        elevation: 0,
        leading: ChunkyIconButton(
          size: 40,
          borderDepth: 3,
          backgroundColor: AppColors.surfaceContainer,
          borderColor: const Color(0xFFD6C4AC),
          icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isUnlocked ? 'Góc Ba Mẹ Quản Lý' : 'Khóa Phụ Huynh An Toàn',
          style: AppTypography.headlineMd(color: AppColors.primary),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: _isUnlocked ? _buildDashboard(state) : _buildPinGate(),
      ),
    );
  }

  Widget _buildPinGate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Parent Gate Hero Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Color(0xFFE4E2DD), offset: Offset(0, 6), blurRadius: 0),
              BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primaryFixed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_rounded, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('Cổng An Toàn Cho Bé', style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Khu Vực Dành Cho Ba Mẹ 👨‍👩‍👧‍👦',
                style: AppTypography.headlineMd(color: AppColors.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Bé yêu hãy nhờ Ba hoặc Mẹ mở khóa giúp nhé!',
                style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Math Challenge Banner (COPPA Verification Standard)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text('Câu đố xác minh người lớn:', style: AppTypography.labelSm(color: AppColors.secondary)),
                    const SizedBox(height: 4),
                    Text('Bảy cộng năm bằng bao nhiêu?', style: AppTypography.headlineMd(color: AppColors.onSurface)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text('( 7 + 5 = ? )', style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _enteredPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isFilled ? AppColors.primaryContainer : AppColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isFilled ? const Color(0xFFD99800) : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(_statusText, style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Keypad (1 - 9, Xóa, 0, Backspace)
        Container(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            children: [
              Row(
                children: [
                  _buildKeypadButton('1'),
                  const SizedBox(width: 10),
                  _buildKeypadButton('2'),
                  const SizedBox(width: 10),
                  _buildKeypadButton('3'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildKeypadButton('4'),
                  const SizedBox(width: 10),
                  _buildKeypadButton('5'),
                  const SizedBox(width: 10),
                  _buildKeypadButton('6'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildKeypadButton('7'),
                  const SizedBox(width: 10),
                  _buildKeypadButton('8'),
                  const SizedBox(width: 10),
                  _buildKeypadButton('9'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ChunkyButton(
                      height: 52,
                      borderDepth: 3,
                      backgroundColor: AppColors.surfaceContainerLow,
                      borderColor: const Color(0xFFD6C4AC),
                      foregroundColor: AppColors.onSurfaceVariant,
                      onPressed: _handleClear,
                      child: Text('Xóa', style: AppTypography.labelMd(color: AppColors.onSurfaceVariant)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildKeypadButton('0'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChunkyButton(
                      height: 52,
                      borderDepth: 3,
                      backgroundColor: AppColors.surfaceContainerLow,
                      borderColor: const Color(0xFFD6C4AC),
                      foregroundColor: AppColors.secondary,
                      onPressed: _handleBackspace,
                      child: const Icon(Icons.backspace_rounded, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildKeypadButton(String digit) {
    return Expanded(
      child: ChunkyButton(
        height: 52,
        borderDepth: 3,
        backgroundColor: AppColors.surfaceContainer,
        borderColor: const Color(0xFFD6C4AC),
        foregroundColor: AppColors.onSurface,
        onPressed: () => _handleNumberTap(digit),
        child: Text(digit, style: AppTypography.headlineMd(color: AppColors.onSurface)),
      ),
    );
  }

  Widget _buildDashboard(AppState state) {
    final pendingChars = state.characters.where((c) => !c.isParentApproved).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryFixed,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Color(0xFFE6BE8A), offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              const Icon(Icons.family_restroom_rounded, size: 36, color: AppColors.onPrimaryFixed),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Xin chào Ba Mẹ! 👨‍👩‍👧‍👦', style: AppTypography.headlineMd(color: AppColors.onPrimaryFixed)),
                    Text(
                      'Kiểm soát an toàn và xem hành trình học tập của ${state.kidName}',
                      style: AppTypography.bodyMd(color: AppColors.onPrimaryFixed),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Section 1: Character Approvals
        Text('DUYỆT NHÂN VẬT BÉ VẼ', style: AppTypography.labelMd(color: AppColors.primary)),
        const SizedBox(height: 8),
        if (pendingChars.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.accentMintDark),
                const SizedBox(width: 10),
                Text('Tất cả nhân vật của bé đều đã được duyệt! ✨', style: AppTypography.bodyMd(color: AppColors.onSurface)),
              ],
            ),
          )
        else
          Column(
            children: pendingChars.map((char) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [BoxShadow(color: Color(0xFFE4E2DD), offset: Offset(0, 3))],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        char.avatar3dUrl,
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(width: 54, height: 54, color: AppColors.primaryContainer),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(char.name, style: AppTypography.headlineMd(color: AppColors.onSurface)),
                          Text(char.title, style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    ChunkyButton(
                      height: 38,
                      borderDepth: 3,
                      backgroundColor: AppColors.accentMint,
                      borderColor: AppColors.accentMintDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      onPressed: () {
                        state.approveCharacter(char.id);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã duyệt nhân vật ${char.name}! 🌟')),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('Duyệt', style: AppTypography.labelSm(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 18),

        // Section 2: Screen Time Management
        Text('THỜI GIAN SỬ DỤNG MÀN HÌNH', style: AppTypography.labelMd(color: AppColors.primary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Color(0xFFE4E2DD), offset: Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hôm nay bé đã dùng:', style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant)),
                  Text(
                    '${state.screenTimeUsedToday} / ${state.screenTimeMinutesAllowed} phút',
                    style: AppTypography.headlineMd(color: AppColors.secondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Giới hạn thời gian mỗi ngày:', style: AppTypography.labelSm(color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Row(
                children: [30, 45, 60].map((mins) {
                  final isSelected = (state.screenTimeMinutesAllowed == mins);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        state.setScreenTimeLimit(mins);
                        setState(() {});
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFD99800) : const Color(0xFFD6C4AC),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$mins phút',
                            style: AppTypography.labelMd(
                              color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Done button
        ChunkyButton(
          height: 52,
          borderDepth: 4,
          backgroundColor: AppColors.primaryContainer,
          borderColor: const Color(0xFFD99800),
          foregroundColor: AppColors.onPrimaryContainer,
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Hoàn tất & Quay lại', style: AppTypography.labelLg(color: AppColors.onPrimaryContainer)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
