import 'package:flutter/material.dart';

/// ⏳ Pop-up cảnh báo khi nhân vật chưa được Ba Mẹ phê duyệt
class RoleUnapprovedWarningDialog extends StatelessWidget {
  final String charName;

  const RoleUnapprovedWarningDialog({super.key, required this.charName});

  static Future<void> show(BuildContext context, String charName) {
    return showDialog(
      context: context,
      builder: (_) => RoleUnapprovedWarningDialog(charName: charName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.hourglass_empty_rounded, size: 20, color: Color(0xFFF59E0B)),
          SizedBox(width: 8),
          Text('Chờ Ba Mẹ Duyệt', style: TextStyle(fontSize: 16)),
        ],
      ),
      content: Text(
        'Bạn nhỏ "$charName" đang chờ Ba Mẹ duyệt. Bé hãy nhờ Ba Mẹ duyệt trước khi mang bạn vào kể chuyện nhé.',
        style: const TextStyle(fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đã hiểu'),
        ),
      ],
    );
  }
}

