import 'package:flutter/material.dart';

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
            color: Colors.grey,
          ),
          Text(
            '아래로 스크롤하여 운동 기록 보기',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
