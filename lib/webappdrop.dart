import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'package:flutter/widgets.dart';
import 'package:treedraw/appdrop.dart';
import 'package:treedraw/treeutil.dart';

enum _DragState {
  dragging,
  notDragging,
}

AppDrop getAppDrop(TreeUtil treeutil) => AppDrop(treeutil);

class AppDrop {
  StreamSubscription<MouseEvent> _onDragOverSubscription;
  StreamSubscription<MouseEvent> _onDropSubscription;

  final StreamController<Point<double>> _pointStreamController =
      new StreamController<Point<double>>.broadcast();
  final StreamController<_DragState> _dragStateStreamController =
      new StreamController<_DragState>.broadcast();

  TreeUtil treeutil;
  State state;

  AppDrop(TreeUtil treeutil) {
    this.treeutil = treeutil;
  }

  @override
  void dispose() {
    this._onDropSubscription.cancel();
    this._onDragOverSubscription.cancel();
    this._pointStreamController.close();
    this._dragStateStreamController.close();
  }

  @override
  void init(State state) {
    this.state = state;
    this._onDropSubscription = document.body.onDrop.listen(_onDrop);
    this._onDragOverSubscription = document.body.onDragOver.listen(_onDragOver);
  }

  void _onDrop(MouseEvent value) {
    value.stopPropagation();
    value.preventDefault();
    _pointStreamController.sink.add(null);
    _addTree(value.dataTransfer.getData("text"));
  }

  void _addTree(String tree) {
    state.setState(() {
      if (tree != null && tree.length > 1) {
        treeutil.init(tree, false, null, null, false, null, null, false);
        //treeutil = TreeUtil.fromTree(tree);
        //treeDraw = TreeDraw.withTreeUtil(treeutil);
      }
      //debugPrint(tree);
      /*this._files = this._files..addAll(newFiles);

      /// TODO
      print(this._files);*/
    });
  }

  void _onDragOver(MouseEvent value) {
    value.stopPropagation();
    value.preventDefault();
    this
        ._pointStreamController
        .sink
        .add(Point<double>(value.layer.x.toDouble(), value.layer.y.toDouble()));
    this._dragStateStreamController.sink.add(_DragState.dragging);
  }
}
