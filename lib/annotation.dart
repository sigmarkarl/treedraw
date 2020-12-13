import 'dart:collection';
import 'dart:core';
import 'dart:math';
import 'sequence.dart';

class Annotation implements Comparable<Annotation> {
  Sequence seq;
  String name;
  String desc;
  String type;
  String group;
  int start;
  int stop;
  int ori;
  Object color;

  Annotation.withStartStop(Sequence seq, String name, Object color, int start,
      int stop, Map<String, Annotation> mann) {
    Annotation(seq, name, color, mann);
    this.setStart(start);
    this.setStop(stop);
  }

  Annotation(
      Sequence seq, String name, Object color, Map<String, Annotation> mann) {
    this.name = name;
    this.color = color;
    this.seq = seq;

    if (seq != null) {
      seq.addAnnotation(this);
    }
    mann[name] = this;
  }

  bool isGlobal() {
    return seq == null;
  }

  int getLength() {
    return stop - start;
  }

  int getStart() {
    return start;
  }

  int getEnd() {
    return stop;
  }

  void setStart(int start) {
    this.start = start;
  }

  void setStop(int stop) {
    this.stop = stop;
  }

  void setOri(int ori) {
    this.ori = ori;
  }

  void setGroup(String group) {
    this.group = group;
  }

  void setType(String type) {
    this.type = type;
  }

  int getCoordStart() {
    return (seq != null ? seq.getStart() : 0) + start;
  }

  int getCoordEnd() {
    return (seq != null ? seq.getStart() : 0) + stop;
  }

  void append(String astr) {
    if (desc == null)
      desc = astr;
    else
      desc += astr;
  }

  int compareTo(Annotation o) {
    return start - o.start;
  }
}
