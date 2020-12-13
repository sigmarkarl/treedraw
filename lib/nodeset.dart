import 'dart:collection';
import 'dart:core';

class NodeSet implements Comparable<NodeSet> {
  NodeSet(Set<String> nodes) {
    this.nodes = nodes;
    //this.count = count;
  }

  Set<String> nodes;
  Map<String, List<double>> leaveHeightMap =
      new HashMap<String, List<double>>();
  //Map<String,List<Double>>	leaveHeightMap = new HashMap<String,List<Double>>();
  List<double> count = [];
  List<double> boots = [];

  int getCount() {
    return count.length;
  }

  Set<String> getNodes() {
    return nodes;
  }

  void addLeaveHeight(String name, double h) {
    List<double> leaveHeights;
    if (leaveHeightMap.containsKey(name)) {
      leaveHeights = leaveHeightMap[name];
    } else {
      leaveHeights = [];
      leaveHeightMap[name] = leaveHeights;
    }
    leaveHeights.add(h);
  }

  double getAverageLeaveHeight(String name) {
    if (leaveHeightMap.containsKey(name)) {
      List<double> dlist = leaveHeightMap[name];

      double avg = 0.0;

      for (double d in dlist) {
        avg += d;
      }

      avg /= dlist.length;
      return avg;
    }
    return -1.0;
  }

  void addHeight(double h) {
    //if( count == null ) count = new ArrayList<Double>();
    count.add(h);
  }

  void addBootstrap(double h) {
    //if( count == null ) count = new ArrayList<Double>();
    boots.add(h);
  }

  double getAverageHeight() {
    double avg = 0.0;

    for (double d in count) {
      avg += d;
    }

    avg /= count.length;
    return avg;
  }

  double getAverageBootstrap() {
    double avg = 0.0;

    for (double d in boots) {
      avg += d;
    }

    avg /= boots.length;
    return avg;
  }

  int compareTo(NodeSet o) {
    int val = o.count.length - count.length;
    if (val == 0)
      return o.nodes.length - nodes.length;
    else
      return val;
  }
}
