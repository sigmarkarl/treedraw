import 'dart:collection';
import 'dart:core';
import 'dart:math';
import 'annotation.dart';
import 'animap.dart';
import 'revcom.dart';
import 'compliment.dart';

class Sequence implements Comparable<Sequence> {
  /*static int						max = 0;
	static int						min = 0;
	
	static ArrayList<Sequence>		lseq = new ArrayList<Sequence>() {
		private static final long serialVersionUID = 1L;

		bool add( Sequence seq ) {
			seq.index = Sequence.lseq.length;
			return super.add( seq );
		}
	};
	static Map<String,Sequence>		mseq = new HashMap<String,Sequence>();
	static ArrayList<Annotation>	lann = new ArrayList<Annotation>();
	static Map<String,Annotation>	mann = new HashMap<String,Annotation>();*/

  static Animap amimap = Animap();
  static Revcom revcom = Revcom();
  static Compliment complimentMap = Compliment();
  static Map<String, String> rc = Map<String, String>();

  Sequence() {
    rc['A'] = 'T';
    rc['C'] = 'G';
    rc['G'] = 'C';
    rc['T'] = 'A';
  }

  String name;
  String id;
  String sb;
  int start = 0;
  int revcomp = 0;
  int gcp = -1;
  int alignedlength = -1;
  int unalignedlength = -1;
  int substart = -1;
  int substop = 0;
  List<Annotation> annset;
  int index = -1;
  bool edited = false;
  bool selected = false;

  static final Random r = new Random();

  bool isSelected() {
    return selected;
  }

  void setSelected(bool sel) {
    this.selected = sel;
  }

  void removeGaps() {}

  static String getPhylip(List<Sequence> lseq, bool numeric) {
    String out = "";

    for (Sequence seq in lseq) {
      //System.err.println( seq.getName() );
    }

    String erm = lseq.length.toString();
    String seqlen = "";
    for (int i = 0; i < 6 - erm.length; i++) {
      seqlen += " ";
    }
    seqlen += erm;
    int alen = lseq[0].getLength();
    seqlen += "   " + alen.toString();

    out += seqlen + "\n";

    Map<String, int> seqset = new HashMap<String, int>();

    int u = 0;
    int count = 0;
    for (int k = 0; k < alen; k += 50) {
      int seqi = 0;
      for (Sequence seq in lseq) {
        if (u == 0) {
          if (!numeric) {
            String seqname = seq.getName();
            int m = min(seqname.length, 10);

            String subname = seqname.substring(0, m);

            int scount = 1;
            String newname;
            if (seqset.containsKey(subname)) {
              scount = seqset[subname] + 1;
              //if( seqname.length > 10 ) {
              //	subname = seqname.substring( seqname.length-10, seqname.length );
              //} else {
              String cstr = scount.toString();
              m = min(seqname.length, 10 - cstr.length);
              newname = seqname.substring(0, m) + cstr;
              //}
            } else
              newname = subname;
            seqset[subname] = scount;

            out += newname;
            while (m < 10) {
              out += ' ';
              m++;
            }
          } else {
            String sind = (seqi++).toString();

            int m = 0;
            while (m < 10 - sind.length) {
              out += '0';
              m++;
            }
            out += sind;
          }
        } else
          out += "          ";

        for (int l = k; l < min(k + 50, alen); l++) {
          if (l % 10 == 0) {
            out += " ";
          }
          out += seq.charAt(l + seq.getStart());
        }
        out += "\n";
      }
      out += "\n";

      u++;
    }

    return out.toString();
  }

  static List<double> entropy(List<Sequence> lseq) {
    int total = lseq[0].getLength();
    List<double> ret = List.filled(total, 0.0);
    Map<String, int> shanmap = new HashMap<String, int>();
    for (int x = 0; x < total; x++) {
      shanmap.clear();

      int count = 0;
      for (Sequence seq in lseq) {
        String c = seq.charAt(x);
        if (c != '.' && c != '-' && c != ' ' && c != '\n') {
          int val = 0;
          if (shanmap.containsKey(c)) val = shanmap[c];
          shanmap[c] = val + 1;
          count++;
        }
      }

      double res = 0.0;
      for (String c in shanmap.keys) {
        int val = shanmap[c];
        double p = (val as double) / (count as double);
        res -= p * log(p);
      }
      ret[x] = res / log(2.0);
    }
    return ret;
  }

  void distanceMatrixNumeric(List<Sequence> lseq, List<double> dmat,
      List<int> idxs, bool bootstrap, bool cantor, List<double> ent) {
    int len = lseq.length;
    for (int x = 0; x < lseq.length; x++) {
      dmat[x * len + x] = 0.0;
    }
    if (idxs != null && idxs.length > 0) {
      int count = idxs.length;
      for (int x = 0; x < len - 1; x++) {
        for (int y = x + 1; y < len; y++) {
          Sequence seq1 = lseq[x];
          Sequence seq2 = lseq[y];

          //if( seq1 == seq2 ) dmat[i] = 0.0;
          //else {
          double mism = 0;

          if (ent != null) {
            int i = 0;
            if (bootstrap) {
              for (int k in idxs) {
                int ir = r.nextInt(idxs.length);
                int u = idxs[ir];
                String c1 = seq1.charAt(u - seq1.getStart());
                String c2 = seq2.charAt(u - seq2.getStart());

                if (c1 != c2) mism += 1.0 / ent[u];
                //count++;
                i++;
              }
            } else {
              for (int k in idxs) {
                String c1 = seq1.charAt(k - seq1.getStart());
                String c2 = seq2.charAt(k - seq2.getStart());

                if (c1 != c2) mism += 1.0 / ent[k];
                i++;
              }
            }
          } else {
            if (bootstrap) {
              for (int k in idxs) {
                int ir = r.nextInt(idxs.length);
                String c1 = seq1.charAt(idxs[ir] - seq1.getStart());
                String c2 = seq2.charAt(idxs[ir] - seq2.getStart());

                if (c1 != c2) mism++;
              }
            } else {
              for (int k in idxs) {
                String c1 = seq1.charAt(k - seq1.getStart());
                String c2 = seq2.charAt(k - seq2.getStart());

                if (c1 != c2) mism++;
              }
            }
          }
          double d = mism / (count as double);
          if (cantor) d = -3.0 * log(1.0 - 4.0 * d / 3.0) / 4.0;
          dmat[x * len + y] = d;
          dmat[y * len + x] = d;
          //}
          //i++;
        }
      }
    } else {
      for (int x = 0; x < len - 1; x++) {
        for (int y = x + 1; y < len; y++) {
          Sequence seq1 = lseq[x];
          Sequence seq2 = lseq[y];

          int count = 0;
          double mism = 0;

          int start = max(seq1.getRealStart(), seq2.getRealStart());
          int end = min(seq1.getRealStop(), seq2.getRealStop());

          if (ent != null) {
            /*if( start < 0 || end >= ent.length ) {
							System.err.println( "mu " + ent.length );
							System.err.println( start + "  " + end );
						}*/

            if (bootstrap) {
              for (int k = start; k < end; k++) {
                int ir = start + r.nextInt(end - start);
                String c1 = seq1.charAt(ir - seq1.getStart());
                String c2 = seq2.charAt(ir - seq2.getStart());

                if (c1 != '.' &&
                    c1 != '-' &&
                    c1 != ' ' &&
                    c1 != '\n' &&
                    c2 != '.' &&
                    c2 != '-' &&
                    c2 != ' ' &&
                    c2 != '\n') {
                  if (c1 != c2) mism += 1.0 / ent[ir];
                  count++;
                }
              }
            } else {
              for (int k = start; k < end; k++) {
                String c1 = seq1.charAt(k - seq1.getStart());
                String c2 = seq2.charAt(k - seq2.getStart());

                if (c1 != '.' &&
                    c1 != '-' &&
                    c1 != ' ' &&
                    c1 != '\n' &&
                    c2 != '.' &&
                    c2 != '-' &&
                    c2 != ' ' &&
                    c2 != '\n') {
                  if (c1 != c2) {
                    mism += 1.0 / ent[k];
                    /*if( ent[k] == 0.0 ) {
											System.err.println("ok");
										}*/
                  }
                  count++;
                }
              }
            }
          } else {
            if (bootstrap) {
              for (int k = start; k < end; k++) {
                int ir = start + r.nextInt(end - start);
                String c1 = seq1.charAt(ir - seq1.getStart());
                String c2 = seq2.charAt(ir - seq2.getStart());

                if (c1 != '.' &&
                    c1 != '-' &&
                    c1 != ' ' &&
                    c1 != '\n' &&
                    c2 != '.' &&
                    c2 != '-' &&
                    c2 != ' ' &&
                    c2 != '\n') {
                  if (c1 != c2) mism++;
                  count++;
                }
              }
            } else {
              for (int k = start; k < end; k++) {
                String c1 = seq1.charAt(k - seq1.getStart());
                String c2 = seq2.charAt(k - seq2.getStart());

                if (c1 != '.' &&
                    c1 != '-' &&
                    c1 != ' ' &&
                    c1 != '\n' &&
                    c2 != '.' &&
                    c2 != '-' &&
                    c2 != ' ' &&
                    c2 != '\n') {
                  if (c1 != c2) mism++;
                  count++;
                }
              }
            }
          }
          double d = count == 0 ? 0.0 : mism / (count as double);
          if (cantor) d = -3.0 * log(1.0 - 4.0 * d / 3.0) / 4.0;

          dmat[x * len + y] = d;
          dmat[y * len + x] = d;
        }
      }
    }

    //return dmat;
  }

  void reverse() {
    String nsb = "";
    for (int i = getLength() - 1; i >= 0; i--) {
      String c = sb[i];
      nsb += c;
    }
    sb = nsb;
  }

  void complement() {
    String nsb = "";
    for (int i = 0; i < getLength(); i++) {
      String c = sb[i];
      nsb += complimentMap[c];
    }
    sb = nsb;
  }

  void upperCase() {}

  void caseSwap() {}

  void utReplace() {
    int i1 = sb.indexOf("T");
    int i2 = sb.indexOf("U");

    if (i1 == -1) i1 = sb.length;
    if (i2 == -1) i2 = sb.length;

    while (i1 < sb.length || i2 < sb.length) {
      while (i1 < i2) {
        setCharAt(i1, 'U');
        i1 = sb.indexOf("T", i1 + 1);
        if (i1 == -1) i1 = sb.length;
      }

      while (i2 < i1) {
        setCharAt(i2, 'T');
        i2 = sb.indexOf("U", i2 + 1);
        if (i2 == -1) i2 = sb.length;
      }
    }

    i1 = sb.indexOf("t");
    i2 = sb.indexOf("u");

    if (i1 == -1) i1 = sb.length;
    if (i2 == -1) i2 = sb.length;

    while (i1 < sb.length || i2 < sb.length) {
      while (i1 < i2) {
        setCharAt(i1, 'u');
        i1 = sb.indexOf("t", i1 + 1);
        if (i1 == -1) i1 = sb.length;
      }

      while (i2 < i1) {
        setCharAt(i2, 't');
        i2 = sb.indexOf("u", i2 + 1);
        if (i2 == -1) i2 = sb.length;
      }
    }
  }

  bool isEdited() {
    return edited;
  }

  String getId() {
    return id;
  }

  void setId(String id) {
    this.id = id;
  }

  void setSequenceString(String sb) {
    this.sb = sb;
  }

  Sequence.nameId(String id, String name, Map<String, Sequence> mseq) {
    Sequence.name(name, mseq);
    this.id = id;
  }

  Sequence.name(String name, Map<String, Sequence> mseq) {
    this.name = name;
    //sb = StringBuffer();
    if (mseq != null) mseq[name] = this;
  }

  Sequence.id(String id, String name, String sb, Map<String, Sequence> mseq) {
    Sequence.nameBuffer(name, sb, mseq);
    this.id = id;
  }

  Sequence.nameBuffer(String name, String sb, Map<String, Sequence> mseq) {
    this.name = name;
    this.sb = sb;
    this.id = name;
    if (mseq != null) mseq[name] = this;
  }

  List<Annotation> getAnnotations() {
    return annset;
  }

  void addAnnotation(Annotation a) {
    if (annset == null) {
      annset = [];
    }
    annset.add(a);
  }

  String getName() {
    return name;
  }

  void setName(String name) {
    this.name = name;
  }

  /*bool equals( Object obj ) {			
		/*bool ret = name.equals( obj.toString() ); //super.equals( obj );
		System.err.println( "erm " + this.toString() + " " + obj.toString() + "  " + ret );
		return ret;*/			
		return super.equals( obj );
	}*/

  String getStringBuilder() {
    return sb;
  }

  String toString() {
    return name;
  }

  void append(String str) {
    sb += str;
  }

  void deleteCharAt(int i) {
    int ind = i - start;
    if (ind >= 0 && ind < sb.length) {
      sb = sb.substring(0, ind) + sb.substring(i + 1);
      edited = true;
    }
  }

  void delete(int dstart, int dstop) {
    int ind = dstart - start;
    int end = dstop - start;
    if (ind >= 0 && end <= sb.length) {
      sb = sb.substring(0, ind) + sb.substring(end);
      edited = true;
    }
  }

  void clearCharAt(int i) {
    int ind = i - start;
    if (ind >= 0 && ind < sb.length) {
      sb = sb.substring(0, ind) + '-' + sb.substring(ind + 1);
      edited = true;
    }
  }

  void setCharAt(int i, String c) {
    int ind = i - start;
    if (ind >= 0 && ind < sb.length) {
      sb = sb.substring(0, ind) + c + sb.substring(ind + 1);
    }
  }

  String charAt(int i) {
    int ind = i - start;
    if (ind >= 0 && ind < getLength()) {
      return sb[ind];
    }

    return ' ';
  }

  void checkLengths() {
    //int start = -1;
    //int stop = 0;
    int count = 0;
    for (int i = 0; i < sb.length; i++) {
      String c = sb[i];
      if (c != '.' && c != '-' && c != ' ') {
        if (substart == -1) substart = i;
        substop = i;
        count++;
      }
    }
    alignedlength = count;
    unalignedlength = substop - substart;
  }

  int getLength() {
    return sb.length;
  }

  int getAlignedLength() {
    if (alignedlength == -1) {
      checkLengths();
    }
    return alignedlength;
  }

  int getUnalignedLength() {
    if (unalignedlength == -1) {
      checkLengths();
    }
    return unalignedlength;
  }

  int getRealStart() {
    return getStart() + substart;
  }

  int getRealStop() {
    return getStart() + substop;
  }

  int getRealLength() {
    return substop - substart;
  }

  /*void boundsCheck() {
		if( start < min ) min = start;
		if( start+sb.length > max ) max = start+sb.length;
	}*/

  /*interface RunInt {
		void run( Sequence s );
	};
	
	static RunInt runbl = null;
	void setStart( int start ) {
		this.start = start;
		
		if( runbl != null ) runbl.run( this ); //boundsCheck();
	}
	
	void setEnd( int end ) {
		this.start = end-sb.length;
		
		if( runbl != null ) runbl.run( this );
		//boundsCheck();
	}*/

  int getStart() {
    return start;
  }

  int getEnd() {
    return start + sb.length;
  }

  int getRevComp() {
    return revcomp;
  }

  int getGCP() {
    if (gcp == -1 && sb.length > 0) {
      gcp = 0;
      int count = 0;
      for (int i = 0; i < sb.length; i++) {
        String c = sb[i];
        if (c == 'G' || c == 'g' || c == 'C' || c == 'c') {
          gcp++;
          count++;
        } else if (c == 'T' || c == 't' || c == 'A' || c == 'a') {
          count++;
        }
      }
      gcp = count > 0 ? 100 * gcp / count : 0;
    }
    return gcp;
  }

  int compareTo(Sequence o) {
    return start - o.start;
  }

  String getProteinSequence(int start, int stop, int ori) {
    String ret = "";

    //if( stop > sb.length ) {
    //if( stop != end ) {
    //	System.err.println();
    //}

    if (ori == -1) {
      int begin = stop - 1 - 3 * ((stop - start) / 3) as int;

      //String aaa = sb.substring(start-1, start+2);
      //String aa = amimap.get( aaa );

      //String aaa = sb.substring(stop-2, stop+1);
      //String aa = amimap.get( revcom.get(aaa) );

      //System.err.println( aa );
      for (int i = stop - 3; i > begin; i -= 3) {
        String aaa = sb.substring(i, i + 3);
        String aa = amimap[revcom[aaa]];
        if (aa != null)
          ret += i != stop - 3 ? aa : (aa == "V" || aa == "L" ? "M" : aa);
        //else break;
      }
    } else {
      int end = start - 1 + 3 * ((stop - start) / 3) as int;
      for (int i = start - 1; i < end; i += 3) {
        String aaa = sb.substring(i, i + 3);
        String aa = amimap[aaa];
        if (aa != null)
          ret += i != start - 1 ? aa : (aa == "V" || aa == "L" ? "M" : aa);
        //else break;
      }
    }

    return ret;
  }

  String getSubstring(int start, int end) {
    return sb.substring(start, end);
  }
}
