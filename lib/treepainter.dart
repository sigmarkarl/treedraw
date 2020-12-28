import 'dart:ui';
import 'package:flutter/material.dart';
import 'treedraw.dart';
import 'treeutil.dart';

class TreePainter extends CustomPainter {
  TreeDraw treeDraw;

  TreePainter(TreeDraw treeDraw) {
    this.treeDraw = treeDraw;
  }

  @override
  void paint(Canvas canvas, Size size) {
    treeDraw.handleTree(canvas, size);
    //treeDraw.drawTree(canvas, size, treeUtil);
    /*var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color(0xff00ff00);
    var rect = Rect.fromLTWH(0, 0, size.width + 100, size.height + 100);
    canvas.drawRect(rect, paint);*/
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
