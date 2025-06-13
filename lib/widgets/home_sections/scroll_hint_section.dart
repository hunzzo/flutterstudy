import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ScrollHintSection extends StatelessWidget {
  const ScrollHintSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: const [
          Icon(
            Icons.keyboard_arrow_down,
            size: 30,
            color: AppColors.hint,
          ),
          Text(
            '아래로 스크롤하여 운동 기록 보기',
            style: TextStyle(color: AppColors.hint, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
