import 'dart:collection';
import 'dart:core';
import 'dart:math';
import 'node.dart';

class TreeUtil {
  Node currentNode = null;
  String treelabel = null;

  TreeUtil.fromTree(String tree) {
    init(tree, false, null, null, false, null, null, false);
  }

  Node removeRoot(Node n) {
    Node ret;
    List<Node> ln = n.getNodes();
    Node n1 = ln[0];
    Node n2 = ln[1];
    if (n1.getNodes() != null && n1.getNodes().length > 0) {
      n1.addNode(n2, n1.geth() + n2.geth());
      n1.setParent(null);
      ret = n1;
    } else {
      n2.addNode(n1, n2.geth() + n2.geth());
      n2.setParent(null);
      ret = n2;
    }
    ret.countLeaves();

    return ret;
  }

  Node getParent(Node root, Set<String> leaveNames) {
    Set<String> currentLeaveNames = root.getLeaveNames();
    if (currentLeaveNames.length >= leaveNames.length) {
      //System.err.println( currentLeaveNames );
      if (currentLeaveNames == leaveNames)
        return root;
      else {
        for (Node n in root.getNodes()) {
          Node par = getParent(n, leaveNames);
          if (par != null) return par;
        }
      }
    }

    return null;
  }

  String getSelectString(Node n, bool meta) {
    String ret = "";
    if (n.isLeaf()) {
      if (n.isSelected())
        ret += n
            .toStringWoLengths(); //meta ? (n.getMeta() != null ? n.getMeta() : n.getName()) : n.getName();
    } else
      for (Node nn in n.getNodes()) {
        String selstr = getSelectString(nn, meta);
        if (selstr.length > 0) {
          if (ret.length == 0)
            ret += getSelectString(nn, meta);
          else
            ret += "," + getSelectString(nn, meta);
        }
      }
    return ret;
  }

  void reduceParentSize(Node n, double scale) {
    List<Node> nodes = n.getNodes();
    if (nodes != null && nodes.length > 0) {
      for (Node node in nodes) {
        reduceParentSize(node, scale);
      }
      if (n.getFontSize() != -1.0 && n.getFontSize() != 0.0)
        n.setFontSize(n.getFontSize() * scale);
      else
        n.setFontSize(0.8);
    }
  }

  void propogateSelection(Set<String> selset, Node node) {
    List<Node> nodes = node.getNodes();
    if (nodes != null) {
      for (Node n in nodes) {
        propogateSelection(selset, n);
      }
    }
    if (node.isLeaf() &&
        (selset.contains(node.toStringWoLengths()) ||
            selset.contains(node.getName()))) node.setSelected(true);
    //else node.setSelected( false );
  }

  void invertSelectionRecursive(Node root) {
    root.setSelected(!root.isSelected());
    if (root.getNodes() != null)
      for (Node n in root.getNodes()) {
        invertSelectionRecursive(n);
      }
  }

  bool isChildSelected(Node n) {
    if (n.isSelected()) return true;

    List<Node> nodes = n.getNodes();
    if (nodes != null) {
      for (Node node in nodes) {
        if (isChildSelected(node)) return true;
      }
    }

    return false;
  }

  bool retainSelection(Node n) {
    if (isChildSelected(n)) {
      List<Node> nodes = n.getNodes();
      if (nodes != null) {
        Node rem = null;
        List<Node> copy = List.of(nodes);
        for (Node node in copy) {
          if (retainSelection(node)) {
            rem = node;
          }
        }
        if (rem != null) {
          rem.getParent().removeNode(rem);
        }
      }
      return false;
    } else {
      return true;
    }
  }

  void setTreeLabel(String label) {
    this.treelabel = label;
  }

  String getTreeLabel() {
    return this.treelabel;
  }

  bool isRooted() {
    return currentNode.getNodes().length == 2;
  }

  void propogateCompare(Node n) {
    if (n.getNodes().length > 0) {
      n.comp++;
      for (Node nn in n.getNodes()) {
        propogateCompare(nn);
      }
    }
  }

  void appendCompare(Node n) {
    if (n.getNodes().length > 0) {
      n.name = n.comp.toString();
      for (Node nn in n.getNodes()) {
        appendCompare(nn);
      }
    }
  }

  Node findNodeBySubtree(Node root, String subtree) {
    Node ret = null;

    String rn = root.toStringWoLengths();
    if (rn == subtree)
      ret = root;
    else if (rn.length > subtree.length) {
      for (Node n in root.getNodes()) {
        Node nn = findNodeBySubtree(n, subtree);
        if (nn != null) {
          ret = nn;
          break;
        }
      }
    }

    return ret;
  }

  void compareTrees(String ns1, Node n1, Node n2) {
    if (n2.getNodes().length > 1) {
      String ns2 = n2.toStringWoLengths();

      if (ns1.contains(ns2)) {
        Node n = findNodeBySubtree(n1, ns2);
        propogateCompare(n);
      } else {
        for (Node n in n2.getNodes()) {
          compareTrees(ns1, n1, n);
        }
      }
    }
  }

  void arrange(Node root, Comparator<Node> comparator) {
    List<Node> nodes = root.getNodes();
    if (nodes != null) {
      for (Node n in nodes) {
        arrange(n, comparator);
      }
      nodes.sort(comparator);
    }
  }

  List<List<double>> lms(
      List<double> distmat, List<String> corrInd, Node toptree) {
    int len = corrInd.length;
    List<Node> nodes = this.getLeaves(toptree);
    int c = 0;
    for (String s in corrInd) {
      int i = c;
      while (s != nodes[i].getName()) i++;

      Node tnode = nodes[c];
      nodes[c] = nodes[i];
      nodes[i] = tnode;

      c++;
    }

    List<double> lad = [];
    for (int y = 0; y < corrInd.length - 1; y++) {
      for (int x = y + 1; x < corrInd.length; x++) {
        lad.add(distmat[y * corrInd.length + x]);
      }
    }
    List<double> d = List.filled(lad.length, 0.0);
    int count = 0;
    for (double dval in lad) {
      d[count++] = dval;
    }

    int nodecount = toptree.countSubnodes();
    List<List<double>> X = List.filled(lad.length, List.filled(nodecount, 0.0));
    for (int k = 0; k < nodecount; k++) {
      for (int y = 0; y < corrInd.length - 1; y++) {
        Node ny = nodes[y];
        for (int x = y + 1; x < corrInd.length; x++) {
          Node nx = nodes[x];
        }
      }
    }

    return X;
  }

  Node neighborJoin(List<double> corrarr, List<String> corrInd, Node guideTree,
      bool rootTree) {
    Node retnode = new Node();
    try {
      List<Node> nodes;
      int len = corrInd.length;
      if (guideTree != null) {
        nodes = this.getLeaves(guideTree);
        int c = 0;
        for (String s in corrInd) {
          int i = c;
          while (s != nodes[i].getName()) i++;

          Node tnode = nodes[c];
          nodes[c] = nodes[i];
          nodes[i] = tnode;

          c++;
        }
      } else {
        nodes = [];
        for (String name in corrInd) {
          Node n = new Node.withName(name);
          nodes.add(n);
        }
      }

      List<double> dmat = corrarr; //new double[len*len];
      List<double> u = List.filled(len, 0.0);
      //System.arraycopy(corrarr, 0, dmat, 0, len*len);
      while (len > 2) {
        //System.err.println( "trying " + len + " size is " + nodes.length );
        for (int i = 0; i < len; i++) {
          u[i] = 0;
          for (int j = 0; j < len; j++) {
            if (i != j) {
              double dval = dmat[i * len + j];
              if (dval.isNaN) {
                //System.err.println("erm");
              }
              u[i] += dval;
            }
          }
          u[i] /= len - 2;
        }

        int imin = 0;
        int jmin = 1;
        double dmin = double.maxFinite;

        if (guideTree == null) {
          for (int i = 0; i < len - 1; i++) {
            for (int j = i + 1; j < len; j++) {
              //if( i != j ) {
              double val = dmat[i * len + j] - u[i] - u[j];
              //if( dmat[i*len+j] < 50 ) System.err.println("euff " + val + " " + i + " " + j + "  " + dmat[i*len+j] );
              if (val < dmin) {
                dmin = val;
                imin = i;
                jmin = j;
              }
              //}
            }
          }
        } else {
          for (int i = 0; i < len - 1; i++) {
            for (int j = i + 1; j < len; j++) {
              Node iparent = nodes[i].getParent();
              Node jparent = nodes[j].getParent();
              if (iparent == jparent) {
                double val = dmat[i * len + j] - u[i] - u[j];
                //if( dmat[i*len+j] < 50 ) System.err.println("euff " + val + " " + i + " " + j + "  " + dmat[i*len+j] );
                if (val < dmin) {
                  dmin = val;
                  imin = i;
                  jmin = j;
                }
              }
            }
          }
        }

        //System.err.println( dmat[imin*len+jmin] );
        double vi = (dmat[imin * len + jmin] + u[imin] - u[jmin]) / 2.0;
        double vj = (dmat[imin * len + jmin] + u[jmin] - u[imin]) / 2.0;

        Node parnode;
        Node nodi = nodes[imin];
        Node nodj = nodes[jmin];
        if (guideTree == null) {
          parnode = new Node();
          parnode.addNode(nodi, vi);
          parnode.addNode(nodj, vj);
        } else {
          parnode = nodi.getParent();
          nodi.seth(vi);
          nodj.seth(vj);
        }

        if (imin > jmin) {
          nodes.remove(imin);
          nodes.remove(jmin);
        } else {
          nodes.remove(jmin);
          nodes.remove(imin);
        }
        nodes.add(parnode);

        List<double> dmatmp = List.filled((len - 1) * (len - 1), 0.0);
        int k = 0;
        //bool done = false;
        for (int i = 0; i < len; i++) {
          if (i != imin && i != jmin) {
            for (int j = 0; j < len; j++) {
              if (j != imin && j != jmin) {
                /*if( k >= dmatmp.length ) {
									System.err.println();
								}*/
                /*if( k >= dmatmp.length ) {
									System.err.println("ok");
								}*/
                dmatmp[k] = dmat[i * len + j];
                k++;
              }
            }

            k++;

            //done = true;
          }
        }
        k = 0;
        for (int i = 0; i < len; i++) {
          if (i != imin && i != jmin) {
            dmatmp[((k++) + 1) * (len - 1) - 1] = (dmat[imin * len + i] +
                    dmat[jmin * len + i] -
                    dmat[imin * len + jmin]) /
                2.0;
          }
        }
        k = 0;
        for (int i = 0; i < len; i++) {
          if (i != imin && i != jmin) {
            dmatmp[(len - 2) * (len - 1) + (k++)] = (dmat[i * len + imin] +
                    dmat[i * len + jmin] -
                    dmat[jmin * len + imin]) /
                2.0;
          }
        }
        len--;
        dmat = dmatmp;

        //System.err.println( "size is " + nodes.length );
      }

      if (rootTree) {
        retnode.addNode(nodes[0], dmat[1]);
        retnode.addNode(nodes[1], dmat[2]);
      } else {
        retnode = nodes[0];
        retnode.seth(0);
        retnode.setParent(null);
        retnode.addNode(nodes[1], dmat[1] + dmat[2]);
      }
      nodes.clear();
    } on Exception {
      //e.printStackTrace();
      //console( e.getMessage() );
    }

    retnode.countLeaves();
    return retnode;
  }

  Node getNode() {
    return currentNode;
  }

  void setNode(Node node) {
    currentNode = node;
  }

  void grisj(Node startNode) {
    List<Node> lnodes = startNode.getNodes();
    if (lnodes != null) {
      List<Node> kvislist = [];
      for (Node n in lnodes) {
        if (!n.isLeaf()) {
          kvislist.add(n);
        }
      }

      if (kvislist.length == 0) {
        Node longestNode = null;
        double h = -1.0;
        for (Node n in lnodes) {
          if (n.geth() > h) {
            h = n.geth();
            longestNode = n;
          }
        }
        if (longestNode != null) startNode.removeNode(longestNode);
      } else {
        for (Node n in kvislist) {
          grisj(n);
        }
      }
    }
  }

  Node getValidNode(Set<String> s, Node n) {
    List<Node> subn = n.getNodes();
    if (subn != null) {
      for (Node sn in subn) {
        Set<String> ln = sn.getLeaveNames();
        if (ln.containsAll(s)) {
          return getValidNode(s, sn);
        }
      }
    }
    return n;
  }

  bool isValidSet(Set<String> s, Node n) {
    if (n.countLeaves() > s.length) {
      List<Node> subn = n.getNodes();
      if (subn != null) {
        for (Node sn in subn) {
          Set<String> lns = sn.getLeaveNames();
          int cntcnt = 0;
          for (String ln in lns) {
            if (s.contains(ln)) cntcnt++;
          }
          if (!(cntcnt == 0 || cntcnt == lns.length)) {
            return false;
          }
        }
      }
      return true;
    }
    return false;
  }

  Node getConnectingParent(Node leaf1, Node leaf2) {
    Set<Node> ns = new HashSet<Node>();
    Node parent1 = leaf1.getParent();
    while (parent1 != null) {
      ns.add(parent1);
      parent1 = parent1.getParent();
    }

    Node parent2 = leaf2.getParent();
    while (parent2 != null) {
      if (ns.contains(parent2)) break;
      parent2 = parent2.getParent();
    }

    return parent2;
  }

  List<double> getDistanceMatrix(List<Node> leaves) {
    List<double> ret = List.filled(leaves.length * leaves.length, 0.0);

    for (int i = 0; i < leaves.length; i++) {
      ret[i + i * leaves.length] = 0.0;
    }

    for (int i = 0; i < leaves.length; i++) {
      for (int k = i + 1; k < leaves.length; k++) {
        Node leaf1 = leaves[i];
        Node leaf2 = leaves[k];
        Node parent = getConnectingParent(leaf1, leaf2);
        double val = 0.0;

        Node par = leaf1.getParent();
        while (par != parent) {
          val += leaf1.geth();
          leaf1 = par;
          par = leaf1.getParent();
        }
        val += leaf1.geth();

        par = leaf2.getParent();
        while (par != parent) {
          val += leaf2.geth();
          leaf2 = par;
          par = leaf2.getParent();
        }
        val += leaf2.geth();

        ret[i + k * leaves.length] = val;
        ret[k + i * leaves.length] = val;
      }
    }

    return ret;
  }

  Set<String> getLeaveNames(Node node) {
    Set<String> ret = new HashSet<String>();

    List<Node> nodes = node.getNodes();
    if (nodes != null && nodes.length > 0) {
      for (Node n in nodes) {
        ret.addAll(getLeaveNames(n));
      }
    } else
      ret.add(node.getName());

    return ret;
  }

  List<Node> getLeaves(Node node) {
    List<Node> ret = [];

    List<Node> nodes = node.getNodes();
    if (nodes != null && nodes.length > 0) {
      for (Node n in nodes) {
        ret.addAll(getLeaves(n));
      }
    } else
      ret.add(node);

    return ret;
  }

  List<Node> getSubNodes(Node node) {
    List<Node> ret = [];

    List<Node> nodes = node.getNodes();
    if (nodes != null) {
      for (Node n in nodes) {
        ret.add(n);
        ret.addAll(getSubNodes(n));
      }
    }

    return ret;
  }

  Node findNode(Node old, Node node) {
    for (Node n in old.nodes) {
      if (n == node)
        return old;
      else {
        Node ret = findNode(n, node);
        if (ret != null) return n;
      }
    }
    return null;
  }

  Node findNodeByVal(Node old, double val) {
    for (Node n in old.nodes) {
      if (n.h2 == val)
        return n;
      else {
        Node ret = findNodeByVal(n, val);
        //if( ret != null )
        return ret;
      }
    }
    return null;
  }

  void getlevel(Map<int, Set<Node>> map, Node n, int l) {
    Set<Node> set;
    if (map.containsKey(l)) {
      set = map[l];
    } else {
      set = new HashSet<Node>();
      map[l] = set;
    }
    set.addAll(n.nodes);
    for (Node node in n.nodes) {
      getlevel(map, node, l + 1);
    }
  }

  void propnull(Node n) {
    for (Node node in n.nodes) {
      propnull(node);
    }
    if (n.h < 0.002) n.h = 0.6;
  }

  void extractMetaRecursive(Node node, Map<String, Map<String, String>> mapmap,
      Set<String> collapset, bool collapse) {
    if (node.name != null) extractMeta(node, mapmap);

    List<Node> checklist = node.nodes;
    for (Node subnode in checklist) {
      extractMetaRecursive(subnode, mapmap, collapset, collapse);
    }

    if (mapmap != null && mapmap.length > 0 && checklist.length > 0) {
      String metacheck = null;
      bool dual = true;
      String partial = "";
      for (Node n in checklist) {
        if (n.meta != null) {
          String nmeta = null;
          if (n.name != null && n.name.length > 0) {
            nmeta = n.name.substring(7).trim();

            /*if( n.name.startsWith("T.ign") ) {
							System.err.println();
						}*/
          }

          if (n.meta.contains(";") || (n.nodes != null && n.nodes.length > 0)) {
            List<String> split = n.meta.split(";");
            if (split.length > 2) {
              List<String> msp = split[split.length - 1].split(":");
              String val = null;
              if (msp.length > 1) {
                val = (msp[1].contains("awai") ||
                        msp[1].contains("ibet") ||
                        msp[1].contains("ellow"))
                    ? msp[1].split(" ")[0]
                    : msp[0];
              } else {
                val = msp[0];
              }

              if (nmeta == null)
                nmeta = val;
              else
                nmeta += "-" + val;
            } else if (nmeta == null) nmeta = split[0];

            /*List<String> lsp = nmeta.split("-");
						if( lsp.length > 1 ) {
							List<String> msp = lsp[1].split(":");
							if( msp.length > 1 ) {
								nmeta = lsp[0] + "-" + ((msp.length > 1 && (nmeta.contains("awai") || nmeta.contains("ibet") || nmeta.contains("ellow"))) ? msp[1].split(" ")[0] : msp[0]);
							}
						} else {
							List<String> msp = nmeta.split(":");
							if( msp.length > 1 ) {
								nmeta = (msp.length > 1 && (nmeta.contains("awai") || nmeta.contains("ibet") || nmeta.contains("ellow"))) ? msp[1].split(" ")[0] : msp[0];
							}
						}*/
            //}
          }

          if (nmeta != null) {
            //if( nmeta.contains("oshimai") ) System.err.println( nmeta + "  " + metacheck );

            if (metacheck == null) {
              metacheck = nmeta;
            } else if (nmeta.length == 0 || metacheck.length == 0) {
              //System.err.println( "buuuu " + nmeta + "  " + metacheck);
              dual = false;
            } else {
              if (!collapse) {
                if ((!nmeta.contains(metacheck) &&
                    !metacheck.contains(nmeta))) {
                  List<String> split1 = nmeta.split("-");
                  List<String> split2 = metacheck.split("-");

                  String cont = null;
                  if (split1.length > 1 || split2.length > 1) {
                    Set<String> s1 = Set.of(split1);
                    Set<String> s2 = Set.of(split2);

                    for (String str in s1) {
                      if (s2.contains(str)) {
                        cont = str + "-";
                        break;
                      }
                    }
                  }

                  if (cont != null) {
                    metacheck = cont;
                    partial = cont;
                  } else
                    dual = false;
                } else {
                  if (nmeta.length > metacheck.length) {
                    metacheck =
                        collapset.contains(metacheck) ? nmeta : metacheck;
                  } else {
                    metacheck = collapset.contains(nmeta) ? metacheck : nmeta;
                  }
                  partial = metacheck;
                }
              } else {
                if ((!nmeta.contains(metacheck) ||
                    !metacheck.contains(nmeta))) {
                  dual = false;
                }
              }
            }
          }
        }
      }

      if (dual) {
        //if( metacheck.contains("oshimai") ) System.err.println("dual "+metacheck);
        for (Node n in checklist) {
          if (n.nodes != null && n.nodes.length > 0) {
            //if(n.meta != null) System.err.println("delete meta" + n.meta);
            if (partial.length > 0) {
              if (n.meta != null && partial.length >= n.meta.length) {
                n.meta = null;
              }
              //System.err.println( "meta " + n.meta );
              //n.meta = n.meta.replace(partial, "");
              //n.meta = n.meta.replace("-", "")	;
            } else {
              n.meta = null;
            }
          }
        }
        //List<String> msp = metacheck.split(":");
        //node.meta = (msp.length > 1 && (metacheck.contains("awai") || metacheck.contains("ibet") || metacheck.contains("ellow"))) ? msp[1].split(" ")[0] : msp[0];
        node.meta = metacheck;
      } else
        node.meta = partial;
    }
  }

  Set<Node> includeNodes(Node n, Set<String> include) {
    Set<Node> ret = null;
    if (include.contains(n.name)) {
      ret = new HashSet<Node>();
      ret.add(n);
    }
    for (Node sn in n.nodes) {
      Set<Node> ns = includeNodes(sn, include);
      if (ns != null) {
        if (ret == null)
          ret = ns;
        else
          ret.addAll(ns);
      }
    }

    return ret;
  }

  void includeAlready(Node n, Set<Node> include) {
    if (n.parent != null && !include.contains(n.parent)) {
      /*if( n.parent.name != null || n.parent.name.length > 0 ) {
				System.err.println( "erm " + n.parent.name );
			}*/
      include.add(n.parent);
      includeAlready(n.parent, include);
    }
  }

  void deleteNotContaining(Node n, Set<Node> ns) {
    n.nodes.retainWhere((sn) => ns.contains(sn));
    for (Node sn in n.nodes) {
      deleteNotContaining(sn, ns);
    }
    if (n.nodes.length == 1) {
      Node nn = n.nodes[0];
      //if( nn.nodes.length > 0 ) {
      n.name = nn.name;
      n.meta = nn.meta;
      n.h += nn.h;
      n.nodes = nn.nodes;
      //}
      /*else if( nn.name == null || nn.name.length == 0 ) {
				n.nodes.clear();
				n.nodes = null;
			}*/
    }
  }

  void markColor(Node node, Map<String, String> colormap) {
    if (colormap.containsKey(node.meta)) node.color = colormap[node.meta];
    for (Node n in node.nodes) {
      markColor(n, colormap);
    }
  }

  TreeUtil() {
    //super();
  }

  void recursiveAdd(List<String> list, Node root, int i) {
    Node father = Node.withName(list[i]);
    Node mother = Node.withName(list[i + 1]);
    root.addNode(father, 1.0);
    root.addNode(mother, 1.0);

    if (i * 2 + 1 < list.length) recursiveAdd(list, father, i * 2);
    if ((i + 1) * 2 + 1 < list.length) recursiveAdd(list, mother, (i + 1) * 2);
  }

  String parseNodeList(String nodeStr) {
    List<String> split = nodeStr.split(",");
    Node n = Node.withName(split[1]);
    recursiveAdd(split, n, 2);
    this.setNode(n);
    return n.toString();
  }

  void clearParentNames(Node node) {
    if (node.getNodes() != null && node.getNodes().length > 0) {
      node.setName("");
      for (Node n in node.getNodes()) {
        clearParentNames(n);
      }
    }
  }

  void setLoc(int newloc) {
    this.loc = newloc;
  }

  void init(
      String str,
      bool inverse,
      Set<String> include,
      Map<String, Map<String, String>> mapmap,
      bool collapse,
      Set<String> collapset,
      Map<String, String> colormap,
      bool clearParentNodes) {
    //super();
    loc = 0;
    //System.err.println( str );
    if (str != null && str.length > 0) {
      Node resultnode = parseTreeRecursive(str, inverse);

      if (clearParentNodes) {
        clearParentNames(resultnode);
      }

      if (include == null) {
        include = new HashSet<String>();
        String inc = str.substring(loc + 1).trim();
        if (inc.length > 0 && !inc.startsWith("(")) {
          List<String> split = inc.split(",");
          for (String sp in split) {
            include.add(sp.trim());
          }
        }
      }

      if (include.length > 0) {
        Set<Node> sn = includeNodes(resultnode, include);
        Set<Node> cloneset = Set.of(sn);
        for (Node n in sn) {
          includeAlready(n, cloneset);
        }

        deleteNotContaining(resultnode, cloneset);
        resultnode.h = 0.0;

        /*for( Node n : cloneset ) {
					if( n.name != null && n.name.trim().length > 0 ) System.err.println( "nnnnnnnn " + n.name );
				}*/
      }

      extractMetaRecursive(resultnode, mapmap, collapset, collapse);
      if (colormap != null) {
        markColor(resultnode, colormap);
      }
      if (collapse) {
        collapseTree(resultnode, collapset, false);
      }

      this.setNode(resultnode);
    }
    /*else {
			System.err.println( str );
		}*/
  }

  void collapseTreeAdvanced(Node node, List<String> collapset, bool simple) {
    if (node.nodes != null && node.nodes.length > 0) {
      if (node.nodes.length == 1) {
        Node parent = node.getParent();
        if (parent.getNodes().remove(node)) {
          Node thenode = node.nodes[0];
          thenode.seth(thenode.geth() + node.geth());
          parent.getNodes().add(thenode);
        }
      }

      for (Node n in node.nodes) {
        collapseTreeAdvanced(n, collapset, simple);
      }

      String test = null;
      int count = 0;

      bool collapse = node.nodes.length > 1;
      if (collapse) {
        for (Node n in node.nodes) {
          if (simple) {
            String nname = n.toStringWoLengths();
            if (test == null) {
              test = nname;
            } else if (test.length == 0 || nname.length == 0 || nname != test) {
              //!(nname.contains(test) || test.contains(nname)) ) {
              test = test.length > nname.length ? test : nname;
              collapse = false;
              break;
            }
          } else {
            String nname = n.getName() != null ? n.getName() : "";
            String color = n.getColor();
            if (color != null) {
              nname += "[" + color + "]";
            }
            String frame = n.getFrameString();
            if (frame != null) {
              nname += "{" + frame + "}";
            }
            if (collapset == null || collapset.isEmpty) {
              if (test == null) {
                test = nname;
              } else if (test.length == 0 ||
                  nname.length == 0 ||
                  nname != test) {
                //!(nname.contains(test) || test.contains(nname)) ) {
                test = test.length > nname.length ? test : nname;
                collapse = false;
                break;
              }
            } else {
              if (test == null) {
                for (String s in collapset) {
                  if (nname.contains(s)) {
                    test = s;
                    break;
                  }
                }

                if (test == null) {
                  test = "";
                }
              } else if (!nname.contains(test)) {
                collapse = false;
                break;
              }
            }

            String meta = n.getMeta();
            try {
              if (meta != null && meta.length > 0) {
                int mi = int.parse(meta);
                count += mi;
              } else
                count++;
            } on Exception {
              count++;
            }
          }
        }
      }

      if (collapse && (collapset == null || collapset.contains(test))) {
        node.nodes.clear();
        //node.nodes = null;
        //node.setMeta( Integer.toString(count) );
        if (simple)
          node.setName(test);
        else
          node.setName(test + ";" + count.toString());
      }
    }
  }

  void collapseTreeSimple(Node node, Set<String> collapset) {
    if (node.nodes != null && node.nodes.length > 0) {
      bool check = false;
      for (String s in collapset) {
        if (node.meta != null && node.meta.contains(s)) {
          check = true;
          break;
        }
      }
      if (check) {
        node.name = node.meta;
        node.meta = node.countLeaves().toString();
        node.nodes.clear();
        //node.nodes = null;
      } else {
        for (Node n in node.nodes) {
          collapseTreeSimple(n, collapset);
        }
      }
    }
  }

  void nameParentNodes(Node node) {
    if (node.nodes != null && node.nodes.length > 0) {
      for (Node n in node.nodes) {
        nameParentNodes(n);
      }
      bool check = true;
      String sel = null;
      String col = null;
      for (Node n in node.nodes) {
        if (n.getName() != null && n.getName().length > 0) {
          if (sel == null) {
            sel = n.getName();
            col = n.getColor();
          } else {
            if (sel != n.getName()) {
              check = false;
              break;
            }
          }
        } else
          check = false;
      }
      if (check) {
        for (Node n in node.nodes) {
          if (n.nodes != null && n.nodes.length > 0) {
            n.setName(null);
          }
        }
        String name =
            (col == null || col.length == 0) ? sel : sel + "[" + col + "]";
        node.setName(name);
      }
    }
  }

  void nameParentNodesMeta(Node node) {
    if (node.nodes != null && node.nodes.length > 0) {
      for (Node n in node.nodes) {
        nameParentNodesMeta(n);
      }
      bool check = true;
      String sel = null;
      //String col = null;
      for (Node n in node.nodes) {
        int c1 = n.countMaxHeight();
        /*if( c1 > 4 && n.getMeta() != null && n.getMeta().contains("aquat") ) {
					System.err.println();
				}*/
        if (n.getMeta() != null && n.getMeta().length > 0) {
          if (sel == null) {
            sel = n.getMeta();
            int i1 = sel.indexOf('[');
            if (i1 == -1) i1 = sel.length;
            int i2 = sel.indexOf('{');
            if (i2 == -1) i2 = sel.length;
            int i = min(i1, i2);
            sel = sel.substring(0, i);
            //col = n.getColor();
          } else {
            String nmeta = n.getMeta();
            int i1 = nmeta.indexOf('[');
            if (i1 == -1) i1 = nmeta.length;
            int i2 = nmeta.indexOf('{');
            if (i2 == -1) i2 = nmeta.length;
            int i = min(i1, i2);
            String str = nmeta.substring(0, i);

            if (sel != str) {
              check = false;
              break;
            }
          }
        } else
          check = false;
      }
      if (check) {
        for (Node n in node.nodes) {
          if (n.nodes != null && n.nodes.length > 0) {
            n.setMeta("");
          }
        }
        String meta =
            sel; //(col == null || col.length == 0) ? sel : sel+"["+col+"]";
        node.setMeta(meta);
      }
    }
  }

  bool collapseTree(Node node, Set<String> collapset, bool delete) {
    bool ret = false;

    if (node.nodes != null && node.nodes.length > 0) {
      //Set<Node>	delset = null;
      //if( delete ) delset = new HashSet<Node>();

      bool any = false;
      for (Node n in node.nodes) {
        if (collapseTree(n, collapset, delete)) any = true;
        //else if( delset != null ) delset.add( n );
      }

      //if( delset != null ) node.nodes.removeAll( delset );

      if (any)
        ret = true;
      else {
        if (node.meta != null && node.meta.length > 0) {
          node.name = node.meta;
          node.meta = node.countLeaves().toString();
          node.nodes.clear();
          ret = true;
        }
      }
    }

    return ret;
  }

  double rerootRecur(Node oldnode, Node newnode) {
    for (Node res in oldnode.nodes) {
      double b;
      if (res == newnode)
        b = res.h;
      else
        b = rerootRecur(res, newnode);

      if (b != -1) {
        res.nodes.add(oldnode);
        oldnode.parent = res;

        double tmph = oldnode.h;
        //res.h = oldnode.h;
        oldnode.h = b;
        oldnode.nodes.remove(res);

        setNode(newnode);
        currentNode.countLeaves();

        return tmph;
      }
    }

    return -1;
  }

  void recursiveReroot() {}

  void reroot(Node newnode) {
    rerootRecur(currentNode, newnode);
    setNode(newnode);
    currentNode.countLeaves();

    /*double h = newnode.h;
		
		Node formerparent = newnode.getParent();
		if( formerparent != null ) {
			Node nextparent = formerparent.getParent();
			
			formerparent.nodes.remove( newnode );
			Node newroot = new Node();
			newroot.addNode( newnode, h/2.0 );
			
			Node child = formerparent;
			Node parent = nextparent;
			
			if( parent == null ) {
				for( Node nn : child.getNodes() ) {
					if( nn != child ) {
				//Node erm = child.getNodes().get(0) == newnode ? child.getNodes().get(1) : child.getNodes().get(0);
						newroot.addNode(nn, newnode.h+nn.h);
					}
				}
			} else {
				newroot.addNode( formerparent, h/2.0 );
			}
			
			while( parent != null ) {
				parent.nodes.remove( child );
				
				Node nparent = parent.getParent();
				if( nparent != null ) {
					child.addNode(parent, child.h);
				} else {
					//child.addNode(parent, child.h);
					
					for( Node nn : parent.getNodes() ) {
						if( nn != child ) {
						//Node erm = parent.getNodes().get(0) == child ? parent.getNodes().get(1) : parent.getNodes().get(0);
							child.addNode( nn, child.h+nn.h );
						}
					}
					break;
				}
				
				child = parent;
				parent = nparent;
			}
		
			//newparent.addNode( formerparent, h/2.0 );
			//newnode.setParent( newparent );
			
			currentNode = newroot;
			//console( currentNode.nodes.length );
			currentNode.countLeaves();
		}*/
  }

  double getminh2() {
    return minh2;
  }

  double getmaxh2() {
    return maxh2;
  }

  double getminh() {
    return minh;
  }

  double getmaxh() {
    return maxh;
  }

  double getdiff() {
    return maxh - minh;
  }

  double getdiff2() {
    return maxh2 - minh2;
  }

  static void maintree(List<String> args) {
    String imgType = "png";
    int x = 1024;
    int y = 1024 * 16;
    bool equalHeight = false;
    bool inverse = false;
    bool show = false;
    bool help = false;
    bool vertical = false;
    String export = null;
    String coords = null;
    String metafile = null;

    Map<String, Map<String, String>> mapmap =
        new HashMap<String, Map<String, String>>();

    //char[] cbuf = new char[4096];
    //String sb = String();

    String str = ""; //sb.toString().replaceAll("[\r\n]+", "");
    TreeUtil treeutil = new TreeUtil();
    treeutil.init(str, inverse, null, null, false, null, null, false);
  }

  void softReplaceNames(Node node, Map<String, String> namesMap) {
    List<Node> nodes = node.getNodes();
    for (String key in namesMap.keys) {
      //if( node.getName() != null && node.getName().length > 0 )
      //	System.err.println( "blehehe " + node.getName() );
      if (node.getName() != null && node.getName().contains(key)) {
        node.name = namesMap[key];
      }
    }
    //if( namesMap.containsKey( node.getName() ) ) node.setName( namesMap.get(node.getName()) );
    for (Node n in nodes) {
      softReplaceNames(n, namesMap);
    }
  }

  void replaceNames(Node node, Map<String, String> namesMap) {
    List<Node> nodes = node.getNodes();
    if (nodes == null || nodes.length == 0) {
      if (namesMap.containsKey(node.getName()))
        node.setName(namesMap[node.getName()]);
    } else {
      for (Node n in nodes) {
        replaceNames(n, namesMap);
      }
    }
  }

  void swapNamesMeta(Node node) {
    List<Node> nodes = node.getNodes();
    if (nodes != null) {
      for (Node n in nodes) {
        swapNamesMeta(n);
      }
    }
    String meta = node.getMeta();
    String name = node.getName() == null ? "" : node.getName();
    name =
        node.getColor() == null ? name : (name + "[" + node.getColor() + "]");
    if (node.infolist != null) {
      for (String info in node.infolist) name += info;
    }
    name = node.getFrameString() == null
        ? name
        : name + "{" + node.getFrameString() + "}";
    if (meta != null && meta.length > 0) {
      if (name != null && name.length > 0) {
        node.setName(meta + ";" + name);
      } else {
        node.setName(meta);
      }
    } else {
      node.setName(";" + name);
    }
  }

  void replaceNamesMeta(Node node) {
    List<Node> nodes = node.getNodes();
    if (nodes != null) {
      for (Node n in nodes) {
        replaceNamesMeta(n);
      }
    }
    String meta = node.getMeta();
    String name = node.getName() == null ? "" : node.getName();
    name = node.getColor() == null || node.getColor().length == 0
        ? name
        : (name + "[" + node.getColor() + "]");
    if (node.infolist != null) {
      for (String info in node.infolist) name += info;
    }
    name = node.getFrameString() == null || node.getFrameString().length == 0
        ? name
        : name + "{" + node.getFrameString() + "}";
    if (meta != null && meta.length > 0) {
      if (name != null && name.length > 0) {
        node.setName(meta + ";" + name);
      } else {
        node.setName(meta);
      }
    } else {
      node.setName(name);
    }
  }

  int metacount = 0;
  void extractMeta(Node node, Map<String, Map<String, String>> mapmap) {
    node.name = node.name.replaceAll("'", "");

    int ki = node.name.indexOf(';');
    if (ki != -1) {
      //List<String> metasplit = node.name.split(";");
      node.meta = node.name.substring(ki + 1).trim();
      node.name = node.name.substring(0, ki).trim();

      /*int ct = 1;
			String meta = metasplit[ ct ].trim();
			while( !meta.contains(":") && ct < metasplit.length-1 ) {
				meta = metasplit[ ++ct ];
			}
			
			List<String> msplit = meta.split(":");
			node.meta = meta.contains("awai") || meta.contains("ellow") ? msplit[1].split(" ")[0].trim() : msplit[0].trim();
			metacount++;
			
			*for( String meta : metasplit ) {
				if( meta.contains("name:") ) {
					node.name = meta.substring(5).trim();
				} else if( meta.contains("country:") ) {
					List<String> msplit = meta.substring(8).trim().split(":");
					node.meta = meta.contains("awai") || meta.contains("ellow") ? msplit[1].trim() : msplit[0].trim();
					metacount++;
				}
			}*/
    }

    if (mapmap != null) {
      String mapname = node.name;
      /*int ik = mapname.indexOf('.');
			if( ik != -1 ) {
				mapname = mapname.substring(0, ik);
			}*/

      if (mapmap.containsKey(mapname)) {
        Map<String, String> keyval = mapmap[mapname];

        for (String key in keyval.keys) {
          String meta = keyval[key];

          if (key == "name") {
            node.name = meta.trim();
          } else if (node.meta == null || node.meta.length == 0) {
            node.meta = meta;
          } else {
            node.meta += ";" + meta;
            //node.meta += meta;
          }
        }
        /*if( keyval.containsKey("country") ) {
					String meta = keyval.get("country");
					//int i = meta.indexOf(':');
					//if( i != -1 ) meta = meta.substring(0, i);
					node.meta = meta;
				}
				
				if( keyval.containsKey("full_name") ) {
					String tax = keyval.get("full_name");
					int i = tax.indexOf(':');
					if( i != -1 ) tax = tax.substring(0, i);
					node.name = tax;
				}*/
      }
    }
  }

  double minh = double.maxFinite;
  double maxh = 0.0;
  double minh2 = double.maxFinite;
  double maxh2 = 0.0;
  int loc;
  Node parseTreeRecursive(String str, bool inverse) {
    Node ret = new Node();
    Node node = null;
    while (loc < str.length - 1 && str[loc] != ')') {
      loc++;
      String c = str[loc];
      if (c == '(') {
        node = parseTreeRecursive(str, inverse);
        //if( node.nodes.length == 1573 ) System.err.println( node );
        if (inverse) {
          node.nodes.add(ret);
          ret.parent = node;
          node.leaves++;
        } else {
          ret.nodes.add(node);
          node.parent = ret;
          //if( ret.name != null && ret.name.length > 0 ) System.err.println("fokk you too");
          ret.leaves += node.leaves;
        }
      } else {
        node = new Node();
        int end = loc + 1;
        String n = str[end];

        int si = 0;
        /*if( c == '\'' ) {
					while( end < str.length-1 && n != '\'' ) {
						n = str.charAt(++end);
					}
					si = end-loc-1;
					//String code = str.substring( loc, end );
					//node.name = code.replaceAll("'", "");
					//loc = end+1;
				}*/

        bool outsvig = true;
        bool brakk = n == '[';
        //while( end < str.length-1 && n != ',' && n != ')' ) {
        while (end < str.length - 1 &&
            (brakk || (n != ',' && n != ')' || !outsvig))) {
          n = str[++end];
          if (n == '[') {
            brakk = true;
            //n = str.charAt(++end);
          } else if (n == ']') {
            brakk = false;
            //n = str.charAt(++end);
          } else if (outsvig && n == '(') {
            outsvig = false;
            n = str[++end];
          } else if (!outsvig && n == ')') {
            outsvig = true;
            n = str[++end];
          }

          //end++;
        }

        String code = str.substring(loc, end);
        int ci = code.indexOf(":", si);
        if (ci != -1) {
          List<String> split;
          //int i = code.lastIndexOf("'");
          String name;
          /*if( i > 0 ) {
						split = code.substring(i, code.length).split(":");
						name = code.substring(0, i+1);
					} else {
						split = code.split(":");
						name = split[0];
					}*/

          split = code.split(":");
          name = split[0];

          /*int coli = name.indexOf("[#");
					if( coli != -1 ) {
						int ecoli = name.indexOf("]", coli+2);
						node.color = name.substring(coli+1,ecoli);
						name = name.substring(0, coli);
					}
					
					int idx = name.indexOf(';');
					if( idx == -1 ) {
						node.name = name;
					} else {
						node.name = name.substring(0,idx);
						node.meta = name.substring(idx+1);
					}
					node.id = node.name;*/
          node.setName(name);
          //extractMeta( node, mapmap );

          if (split.length > 2) {
            String color = split[2].substring(0);
            if (color.contains("rgb")) {
              try {
                int co = color.indexOf('(');
                int ce = color.indexOf(')', co + 1);
                List<String> csplit = color.substring(co + 1, ce).split(",");
                int r = int.parse(csplit[0].trim());
                int g = int.parse(csplit[1].trim());
                int b = int.parse(csplit[2].trim());
                node.color = "rgb(" +
                    r.toString() +
                    "," +
                    g.toString() +
                    "," +
                    b.toString() +
                    ")"; //new Color( r,g,b );
              } on Exception {}
            } else {
              try {
                int r = int.parse(color.substring(0, 2), radix: 16);
                int g = int.parse(color.substring(2, 4), radix: 16);
                int b = int.parse(color.substring(4, 6), radix: 16);
                node.color = "rgb(" +
                    r.toString() +
                    "," +
                    g.toString() +
                    "," +
                    b.toString() +
                    ")"; //new Color( r,g,b );
              } on Exception {}
            }
          } // else node.color = null;

          String dstr = split[1].trim();
          /*String dstr2 = "";
					if( dstr.contains("[") ) {
						int start = dstr.indexOf('[');
						int stop = dstr.indexOf(']');
						dstr2 = dstr.substring( start+1, stop );
						dstr = dstr.substring( 0, start );
					}*/

          try {
            node.h = double.parse(dstr);
            /*if( dstr2.length > 0 ) {
							node.h2 = double.parse( dstr2 );
							if( node.name == null || node.name.length == 0 ) {
								node.setName( dstr2 );
								*node.name = dstr2; 
								node.id = node.name;*
							}
						}*/
          } on Exception {
            //System.err.println();
          }

          if (node.h < minh) minh = node.h;
          if (node.h > maxh) maxh = node.h;

          if (node.h2 != null) {
            if (node.h2 < minh2) minh2 = node.h2;
            if (node.h2 > maxh2) maxh2 = node.h2;
          }
        } else {
          node.setName(code);
          /*int idx = code.indexOf(';');
					if( idx == -1 ) {
						node.name = code;
					} else {
						node.name = code.substring(0,idx);
						node.meta = code.substring(idx+1);
					}
					//node.name = code; //code.replaceAll("'", "");
					node.id = node.name;*/
        }
        loc = end;

        if (inverse) {
          node.nodes.add(ret);
          ret.parent = node;
          node.leaves++;
        } else {
          ret.nodes.add(node);
          //if( ret.name != null && ret.name.length > 0 ) System.err.println("fokk");
          node.parent = ret;
          ret.leaves++;
        }
      }
    }

    Node use = inverse ? node : ret;

    /*List<Node> checklist = use.nodes;
		String metacheck = null;
		bool dual = true;
		for( Node n : checklist ) {
			if( n.meta != null ) {
				if( metacheck == null ) metacheck = n.meta;
				else if( !n.meta.equals(metacheck) ) dual = false;
			}
		}
		
		if( dual ) {
			for( Node n : checklist ) {
				if( n.nodes != null && n.nodes.length > 0 ) n.meta = null;
			}
			use.meta = metacheck;
		} else use.meta = "";*/

    //System.err.println("setting: "+metacheck + use.nodes);

    if (loc < str.length - 1) {
      loc++;
      int end = loc;
      String n = str[end];

      int si = 0;
      /*if( n == '\'' ) {
				n = str.charAt(++end);
				while( end < str.length-1 && n != '\'' ) {
					n = str.charAt(++end);
				}
				si = end-loc-1;
				//String code = str.substring( loc, end );
				//node.name = code.replaceAll("'", "");
				//loc = end+1;
			}*/

      bool brakk = n == '[';
      while (end < str.length - 1 && (brakk || (n != ',' && n != ')'))) {
        n = str[++end];
        if (n == '[') {
          brakk = true;
          //n = str.charAt(++end);
        } else if (n == ']') {
          brakk = false;
          //n = str.charAt(++end);
        }
      }

      String code;
      if (n == ']') {
        code = str.substring(loc, end + 1);
      } else
        code = str.substring(loc, end);
      int ci = code.indexOf(":", si);
      if (ci != -1) {
        List<String> split;
        int i = code.lastIndexOf("'");
        if (i > 0) {
          split = code.substring(i, code.length).split(":");
          ret.setName(code.substring(0, i + 1));
        } else {
          split = code.split(":");
          ret.setName(split.length > 0 ? split[0] : "");
        }

        //List<String> split = code.split(":");
        if (split.length > 2) {
          String color = split[2].substring(0);
          try {
            int r = int.parse(color.substring(0, 2), radix: 16);
            int g = int.parse(color.substring(2, 4), radix: 16);
            int b = int.parse(color.substring(4, 6), radix: 16);
            ret.color = "rgb(" +
                r.toString() +
                "," +
                g.toString() +
                "," +
                b.toString() +
                ")"; //new Color( r,g,b );
          } on Exception {}
        } // else ret.color = null;
        String dstr = split.length > 1 ? split[1].trim() : "0";
        /*String dstr2 = "";
				if( dstr.contains("[") ) {
					int start = split[1].indexOf('[');
					int stop = split[1].indexOf(']');
					dstr2 = dstr.substring( start+1, stop );
					dstr = dstr.substring( 0, start );
				}*/
        try {
          ret.h = double.parse(dstr);
          /*if( dstr2.length > 0 ) {
						ret.h2 = double.parse( dstr2 );
						if( ret.name == null || ret.name.length == 0 ) {
							ret.setName( dstr2 );
						}
					}*/
        } on Exception {}
        if (ret.h < minh) minh = ret.h;
        if (ret.h > maxh) maxh = ret.h;
        if (ret.h2 != null) {
          if (ret.h2 < minh2) minh2 = ret.h2;
          if (ret.h2 > maxh2) maxh2 = ret.h2;
        }
      } else {
        ret.setName(code.replaceAll("'", ""));
      }
      loc = end;
    }

    /*if( use.leaves == 1573 ) {
			try {
				FileWriter fw = new FileWriter("/home/sigmar/tree"+(cnt++)+".ntree");
				fw.write( use.toString() );
				fw.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}*/
    return use;
  }

  int cnt = 0;

  double nDistance(Node node1, Node node2) {
    double ret = 0.0;

    List<Set<String>> nlist1 = [];
    node1.nodeCalc(nlist1);

    List<Set<String>> nlist2 = [];
    node2.nodeCalc(nlist2);

    for (Set<String> s1 in nlist1) {
      bool found = false;
      for (Set<String> s2 in nlist2) {
        if (s1.length == s2.length && s1.containsAll(s2)) {
          found = true;
          break;
        }
      }
      if (!found) ret += 1.0;
    }

    for (Set<String> s2 in nlist2) {
      bool found = false;
      for (Set<String> s1 in nlist1) {
        if (s1.length == s2.length && s1.containsAll(s2)) {
          found = true;
          break;
        }
      }
      if (!found) ret += 1.0;
    }

    return ret;
  }
}
