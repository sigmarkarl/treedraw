import 'dart:ui';
import 'package:flutter/material.dart';
import 'treedraw.dart';
import 'treeutil.dart';

class TreePainter extends CustomPainter {
  TreeDraw treeDraw = TreeDraw();
  TreeUtil treeUtil = TreeUtil();

  @override
  void paint(Canvas canvas, Size size) {
    treeDraw.drawTree(treeUtil)
    /*var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color(0xff00ff00);
    var rect = Rect.fromLTWH(0, 0, size.width + 100, size.height + 100);
    canvas.drawRect(rect, paint);*/
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
