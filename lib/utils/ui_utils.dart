import 'package:flutter/widgets.dart';

/// 주어진 [key]를 가진 위젯의 전역 위치와 크기를 반환한다.
Rect? widgetRect(GlobalKey key) {
  final context = key.currentContext;
  if (context == null) return null;
  final box = context.findRenderObject() as RenderBox?;
  if (box == null) return null;
  final topLeft = box.localToGlobal(Offset.zero);
  return topLeft & box.size;
}

