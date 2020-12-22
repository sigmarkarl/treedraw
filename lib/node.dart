import 'dart:collection';
import 'dart:core';
import 'dart:html';
import 'dart:math';
import 'nodeset.dart';

class Node {
  String name;
  String id;
  String meta;
  int metacount;
  String imgurl;
  double h;
  double h2;
  double bootstrap;
  String color;
  List<String> infolist;
  List<Node> nodes;
  int leaves = 0;
  Node parent;
  int comp = 0;
  double fontsize = -1.0;
  double framesize = -1.0;
  double frameoffset = -1.0;

  double canvasx;
  double canvasy;

  String collapsed = null;
  bool selected = false;

  bool isLeaf() {
    return nodes == null || nodes.length == 0;
  }

  bool isExternal() {
    return isLeaf();
  }

  bool isRoot() {
    return getParent() == null;
  }

  Set<String> getLeaveNames() {
    Set<String> ret = new HashSet<String>();

    List<Node> nodes = this.getNodes();
    if (nodes != null && nodes.length > 0) {
      for (Node n in nodes) {
        ret.addAll(n.getLeaveNames());
      }
      if (nodes.length == 1) ret.add(this.getName());
    } else
      ret.add(this.getName());

    return ret;
  }

  Node getRoot() {
    Node root = this;

    Node parent = root.getParent();
    while (parent != null) {
      root = parent;
      parent = root.getParent();
    }

    return root;
  }

  List<String> getInfoList() {
    return infolist;
  }

  Node findNode(String id) {
    if (id == this.id) {
      return this;
    } else {
      for (Node n in this.nodes) {
        Node ret = n.findNode(id);
        if (ret != null) {
          return ret;
        }
      }
    }
    return null;
  }

  Node getOtherChild(Node child) {
    if (nodes != null && nodes.length > 0) {
      int i = nodes.indexOf(child);
      return i == 0 ? nodes[1] : nodes[0];
    }
    return null;
  }

  Node firstLeaf() {
    Node res = null;
    if (nodes == null || nodes.length == 0) {
      res = this;
    } else {
      for (Node subn in nodes) {
        res = subn.firstLeaf();
        break;
      }
    }
    return res;
  }

  Set<String> nodeCalc(List<Set<String>> ls) {
    Set<String> s = new HashSet<String>();
    if (nodes == null || nodes.length == 0) {
      s.add(id);
    } else {
      for (Node subn in nodes) {
        Set<String> set = subn.nodeCalc(ls);
        s.addAll(set);
      }
      ls.add(s);
    }
    return s;
  }

  Set<String> nodeCalcMap(Map<Set<String>, NodeSet> ls) {
    Set<String> s = new HashSet<String>();
    if (nodes == null || nodes.length == 0) {
      s.add(id);
    } else {
      for (Node subn in nodes) {
        Set<String> set = subn.nodeCalcMap(ls);
        s.addAll(set);
      }

      NodeSet heights;
      if (ls.containsKey(s)) {
        heights = ls[s];
        //ls.put( s, ls.get(s)+1 );
      } else {
        heights = new NodeSet(s);
        ls[s] = heights;
      }
      for (Node subn in nodes) {
        if (subn.isLeaf()) {
          //System.err.println( subn.getName() + "  " + subn.geth() );
          heights.addLeaveHeight(subn.getName(), subn.geth());
        }
      }
      heights.addHeight(this.geth());
      heights.addBootstrap(this.getBootstrap());
    }
    return s;
  }

  Set<String> leafIdSet() {
    Set<String> lidSet = new HashSet<String>();

    if (nodes == null || nodes.length == 0) {
      lidSet.add(id);
    } else {
      for (Node subn in nodes) {
        lidSet.addAll(subn.leafIdSet());
      }
    }

    return lidSet;
  }

  String getId() {
    return id;
  }

  void setSelected(bool selected) {
    this.selected = selected;
  }

  bool isSelected() {
    return this.selected;
  }

  bool isCollapsed() {
    return collapsed != null;
  }

  String getCollapsedString() {
    return collapsed;
  }

  void setCollapsed(String collapsed) {
    this.collapsed = collapsed;
  }

  Node() {
    nodes = [];
    metacount = 0;
  }

  Node.withName(String name, [bool parse = true]) {
    Node();
    this.setName(name, parse);
    /*this.name = name;
			this.id = name;*/
  }

  void setCanvasLoc(double x, double y) {
    canvasx = x;
    canvasy = y;
  }

  double getCanvasX() {
    return canvasx;
  }

  double getCanvasY() {
    return canvasy;
  }

  double getBootstrap() {
    return bootstrap;
  }

  double geth2() {
    return h2;
  }

  double geth() {
    return h;
  }

  void setBootstrap(double bootstrap) {
    this.bootstrap = bootstrap;
  }

  void seth(double h) {
    this.h = h;
  }

  void seth2(double h2) {
    this.h2 = h2;
  }

  String toStringWoLengths() {
    return generateString(false);

    /*String str = "";
			if( nodes.length > 0 ) {
				str += "(";
				int i = 0;
				
				*String n1 = nodes.get(0).toStringSortedWoLengths();
				if( nodes.length > 1 ) {
					String n2 = nodes.get(1).toStringSortedWoLengths();
					if( n1.compareTo( n2 ) > 0 ) {
						str += n2+","+n1+")";
					} else {
						str += n1+","+n2+")";
					}
				} else {
					str += n1+")";
				}*
				for( i = 0; i < nodes.length-1; i++ ) {
					str += nodes.get(i).toStringWoLengths()+",";
				}
				str += nodes.get(i).toStringWoLengths()+")";
			}
			
			if( meta != null && meta.length() > 0 ) {
				if( name != null && name.length() > 0 ) str += "'"+name+";"+meta+"'";
				else str += "'"+meta+"'";
			} else if( name != null && name.length() > 0 ) str += name;
			
			return str;*/
  }

  String generateString(bool wlen) {
    String str = "";
    if (nodes.length > 0) {
      str += "(";
      int i = 0;
      for (i = 0; i < nodes.length - 1; i++) {
        str += nodes[i].generateString(wlen) + ",";
      }
      str += nodes[i].generateString(wlen) + ")";
    }

    if (meta != null && meta.length > 0) {
      //System.err.println("muuu " + meta);
      if (name != null && name.length > 0) {
        str += name;
        if (color != null && color.length > 0) str += "[" + color + "]";
        if (infolist != null) {
          for (String info in infolist) {
            str += info;
          }
        }
        String framestr = this.getFrameString();
        if (framestr != null) str += "{" + framestr + "}";
        str += ";" + meta; //"'"+name+";"+meta+"'";
      } else {
        if (color != null && color.length > 0) str += "[" + color + "]";
        if (infolist != null) {
          for (String info in infolist) {
            str += info;
          }
        }
        String framestr = this.getFrameString();
        if (framestr != null) str += "{" + framestr + "}";
        str += ";" + meta; //"'"+meta+"'";
      }
    } else if (name != null && name.length > 0) {
      str += name;
      if (color != null && color.length > 0) str += "[" + color + "]";
      if (infolist != null) {
        for (String info in infolist) {
          str += info;
        }
      }
      String framestr = this.getFrameString();
      if (framestr != null) str += "{" + framestr + "}";
      /*if( fontsize != -1.0 ) {
					if( framesize == -1.0 ) str += "{"+fontsize+"}";
					else str += "{"+fontsize+" "+framesize+"}";
				}*/
    }

    if (wlen) str += ":" + h.toString();
    // change: if( color != null && color.length() > 0 ) str += ":"+color;
    //else str += ":0.0";

    return str;
  }

  String toString() {
    return generateString(true);
  }

  List<Node> getNodes() {
    return nodes;
  }

  void addNode(Node node, double h) {
    if (!nodes.contains(node)) {
      nodes.add(node);
      node.h = h;
      node.setParent(this);
    }
  }

  void removeNode(Node node) {
    nodes.remove(node);
    node.setParent(null);

    if (nodes.length == 1) {
      Node parent = this.getParent();
      if (parent != null && parent.getNodes().remove(this)) {
        Node thenode = nodes[0];
        thenode.seth(thenode.geth() + this.geth());

        String hi = thenode.getName();
        String lo = this.getName();

        if (hi != null && hi.length > 0 && lo != null && lo.length > 0) {
          try {
            double l = double.parse(lo);
            double h = double.parse(hi);

            if (l > h) thenode.setName(lo);
          } on Exception {}
          ;
        }

        parent.getNodes().add(thenode);
        thenode.setParent(parent);
      }
    }
  }

  void addInfo(String info) {
    if (infolist == null) infolist = [];
    infolist.add(info);
  }

  void clearInfo() {
    if (this.infolist != null) this.infolist.clear();
  }

  void setName(String newname, [bool parse = true]) {
    if (parse) {
      if (newname != null) {
        int fi = newname.indexOf(';');
        if (fi == -1) {
          int ci = newname.indexOf("[");
          //int si = newname.indexOf("{");
          /*if( ci == -1 ) {
							if( si == -1 ) {
								this.name = newname;
								this.setFontSize( -1.0 );
							} else {
								this.name = newname.substring(0,si);
								int se = newname.indexOf("}",si+1);
								String mfstr = newname.substring(si+1,se);
								String[] mfsplit = mfstr.split(" ");
								this.setFontSize( Double.parseDouble( mfsplit[0] ) );
								if( mfsplit.length > 1 ) this.setFrameSize( Double.parseDouble( mfsplit[1] ) );
								if( mfsplit.length > 2 ) this.setFrameOffset( Double.parseDouble( mfsplit[2] ) );
							}
							this.setColor( null );
							clearInfo();
						} else {*/
          if (ci >= 0) {
            this.name = newname.substring(0, ci);
            int ce = newname.indexOf("]", ci + 1);
            String metastr = newname.substring(ci + 1, ce);

            int coli = metastr.indexOf("#");
            if (coli >= 0) {
              this.setColor(metastr.substring(coli, coli + 7));
            }
            int si = metastr.indexOf("{");
            if (si == -1) {
              this.setFontSize(-1.0);

              ci = newname.indexOf('[', ce + 1);
              while (ci != -1) {
                String info = newname.substring(ce + 1, ci);
                /*Browser.getWindow().getConsole().log( "bleh "+info + "  " + ce + "  " + ci );
									Browser.getWindow().getConsole().log( metastr );
									Browser.getWindow().getConsole().log( this.name );
									Browser.getWindow().getConsole().log( newname );*/
                addInfo(info);
                ce = newname.indexOf(']', ci + 1);
                addInfo(newname.substring(ci, ce + 1));

                ci = newname.indexOf('[', ce + 1);

                break;
              }
              int vi = min(si, fi);
              if (vi > ce + 1) addInfo(newname.substring(ce + 1, vi));
            } else {
              //this.name = newname.substring(0,Math.min(ci, si));
              /*int se = metastr.indexOf("}",si+1);
								
								ci = newname.indexOf( '[', ce+1 );
								while( ci != -1 && ci < si ) {
									addInfo( newname.substring(ce+1, ci) );
									ce = newname.indexOf( ']', ci+1 );
									addInfo( newname.substring(ci, ce+1) );
									
									ci = newname.indexOf( '[', ce+1 );
								}
								int vi = Math.min(si, fi);
								if( vi > ce+1 ) addInfo( newname.substring(ce+1, vi) );
								
								String mfstr = newname.substring(si+1,se);
								String[] mfsplit = mfstr.split(" ");
								this.setFontSize( Double.parseDouble( mfsplit[0] ) );
								if( mfsplit.length > 1 ) this.setFrameSize( Double.parseDouble( mfsplit[1] ) );
								if( mfsplit.length > 2 ) this.setFrameOffset( Double.parseDouble( mfsplit[2] ) );*/
            }
          } else
            this.name = newname;
          this.id = this.name;
          this.setMeta(null);
        } else {
          this.setName(newname.substring(0, fi));
          this.setMeta(newname.substring(fi + 1));
        }
      } else {
        this.name = newname;
        try {
          double val = double.parse(newname);
          this.setBootstrap(val);
        } on Exception {}
        this.setMeta(null);
        this.setColor(null);
        clearInfo();
      }
    } else {
      this.name = newname;
      /*this.id = newname;
				try {
					double val = Double.parseDouble( newname );
					this.setBootstrap( val );
				} catch( Exception e ) {
					
				}*/
    }
  }

  String getFullname() {
    return "";
  }

  String getName() {
    return name;
  }

  double getFontSize() {
    return fontsize;
  }

  double getFrameSize() {
    return framesize == -1.0 ? fontsize : framesize;
  }

  double getFrameOffset() {
    return frameoffset;
  }

  String getFrameString() {
    if (fontsize != -1.0) {
      if (framesize != -1.0) {
        if (frameoffset != -1.0)
          return fontsize.toString() +
              " " +
              framesize.toString() +
              " " +
              frameoffset.toString();
        return fontsize.toString() + " " + framesize.toString();
      } else {
        return fontsize.toString();
      }
    }

    return null;
  }

  void setFontSize(double fs) {
    this.fontsize = fs;
  }

  void setFrameSize(double fs) {
    this.framesize = fs;
  }

  void setFrameOffset(double fo) {
    this.frameoffset = fo;
  }

  String getMeta() {
    return meta;
  }

  void setMeta(String newmeta) {
    this.meta = newmeta;
  }

  String getColor() {
    return color;
  }

  int getColorInt() {
    return color != null ? int.parse(color, radix: 16) : 0;
  }

  void setColor(String color) {
    this.color = color;
  }

  int countSubnodes() {
    int total = 0;
    if (!isCollapsed() && nodes != null && nodes.length > 0) {
      for (Node node in nodes) {
        total += node.countLeaves();
      }
      total += nodes.length;
    } else
      total = 1;

    return total;
  }

  int countLeaves() {
    int total = 0;
    if (!isCollapsed() && nodes != null && nodes.length > 0) {
      for (Node node in nodes) {
        total += node.countLeaves();
      }
    } else
      total = 1;
    leaves = total;

    return total;
  }

  int getLeavesCount() {
    return leaves;
  }

  int countMaxHeight() {
    int val = 0;
    for (Node node in nodes) {
      val = max(val, node.countMaxHeight());
    }
    return val + 1;
  }

  int countParentHeight() {
    int val = 0;
    Node parent = this.getParent();
    while (parent != null) {
      val++;
      parent = parent.getParent();
    }
    return val;
  }

  double getLength() {
    return geth();
  }

  double getHeight() {
    double h = this.geth();
    double d =
        (h != null ? h : 0.0) + ((parent != null) ? parent.getHeight() : 0.0);
    //console( h + " total " + d );
    return d;
  }

  double getMaxHeight() {
    double max = 0.0;
    for (Node n in nodes) {
      double nmax = n.getMaxHeight();
      if (nmax > max) max = nmax;
    }
    return geth() + max;
  }

  Node getParent() {
    return parent;
  }

  void setParent(Node parent) {
    this.parent = parent;
  }
}
