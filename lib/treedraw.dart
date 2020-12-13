import 'sequence.dart';
import 'treeutil.dart';
import 'node.dart';
import 'dart:math';

class treedraw {
  TreeUtil	treeutil;
  Node root;
  List<Node> nodearray;

  double w;
	double h;
	double dw;
	double dh;

  double fontscale = 5.0;
	double hchunk = 10.0;
	void drawTree( TreeUtil treeutil ) {
		int ww = getClientWidth();
		if( radial ) {
			if( treeutil != null ) {
				Node root = treeutil.getNode();
				//Browser.getWindow().getConsole().log("heyhey");
				count = 0;
				
				Context2d ctx = canvas.getContext2d();
				
				bounds[0] = Double.MAX_VALUE;
				bounds[1] = Double.MAX_VALUE;
				bounds[2] = Double.NEGATIVE_INFINITY;
				bounds[3] = Double.NEGATIVE_INFINITY;
				
				lbounds[0] = Double.MAX_VALUE;
				lbounds[1] = Double.MAX_VALUE;
				lbounds[2] = Double.NEGATIVE_INFINITY;
				lbounds[3] = Double.NEGATIVE_INFINITY;
				
				constructNode( ctx, treeutil, root, 0.0, Math.PI * 2, 0.0, 0.0, 0.0, true );
				
				double xscale = (canvas.getCoordinateSpaceWidth()-10.0-(lbounds[2]-lbounds[0]))/(bounds[2]-bounds[0]);
				//double yscale = (canvas.getCoordinateSpaceHeight()-10.0-(lbounds[3]-lbounds[1]))/(bounds[3]-bounds[1]);
				//double scale = Math.min(xscale, yscale);
				double xoffset = 5.0-lbounds[0]-bounds[0]*xscale;
				double yoffset = 5.0-lbounds[1]-bounds[1]*xscale;
				
				int hval = (int)((bounds[3]-bounds[1])*xscale+(lbounds[3]-lbounds[1])+10);
				canvas.setSize((ww-10)+"px", hval+"px");
				canvas.setCoordinateSpaceWidth( ww-10 );
				canvas.setCoordinateSpaceHeight( hval );
				
				/*if( hchunk != 10.0 ) {
					String fontstr = (int)(fontscale*Math.log(hchunk))+"px sans-serif";
					if( !fontstr.equals(ctx.getFont()) ) ctx.setFont( fontstr );
				}*/
				
				ctx.setFillStyle("#FFFFFF");
				ctx.fillRect(0.0, 0.0, canvas.getCoordinateSpaceWidth(), canvas.getCoordinateSpaceHeight());
				ctx.setStrokeStyle("#000000");
				constructNode( ctx, treeutil, root, 0.0, Math.PI * 2, 0.0, 0.0, 0.0, false );
			}
		} else {
			/*double minh = treeutil.getminh();
			double maxh = treeutil.getmaxh();
			
			double minh2 = treeutil.getminh2();
			double maxh2 = treeutil.getmaxh2();*/
			
			int leaves = root.getLeavesCount();
			int levels = root.countMaxHeight();
			
			nodearray = List.filled(leaves, null);
			
			String treelabel = treeutil.getTreeLabel();
			
			int hsize = (int)(hchunk*leaves);
			if( treelabel != null ) hsize += 2*hchunk;
			if( showscale ) hsize += 2*hchunk;
			if( circular ) {
				canvas.setSize((ww-10)+"px", (ww-10)+"px");
				canvas.setCoordinateSpaceWidth( ww-10 );
				canvas.setCoordinateSpaceHeight( ww-10 );
			} else {
				canvas.setSize((ww-10)+"px", (hsize+2)+"px");
				canvas.setCoordinateSpaceWidth( ww-10 );
				canvas.setCoordinateSpaceHeight( hsize+2 );
			}
			
			bool vertical = true;
			//boolean equalHeight = false;
			
			h = hchunk*leaves; //circular ? ww-10 : hchunk*leaves;
			w = ww - 10.0;
			
			if( vertical ) {
				dh = hchunk;
				dw = w/levels;
			} else {
				dh = h/levels;
				dw = w/leaves;
			}
			
			int starty = 10; //h/25;
			int startx = 10; //w/25;
			//GradientPaint shadeColor = createGradient( color, ny-k/2, h );
			//drawFramesRecursive( g2, resultnode, 0, 0, w/2, starty, paint ? shadeColor : null, leaves, equalHeight );
			
			ci = 0;
			//g2.setFont( dFont );
			
			//console( Double.toString( maxheight ) );
			//console( Double.toString( maxh-minh ) );
			//console( Double.toString(maxh2-minh2) );
			
			Context2d ctx = canvas.getContext2d();
			ctx.setFillStyle("#FFFFFF");
			ctx.fillRect(0.0, 0.0, canvas.getCoordinateSpaceWidth(), canvas.getCoordinateSpaceHeight());
			if( hchunk != 10.0 ) {
				String fontstr = (int)(fontscale*Math.log(hchunk))+"px sans-serif";
				if( !fontstr.equals(ctx.getFont()) ) ctx.setFont( fontstr );
			}
			if( treelabel != null ) {
				ctx.setFillStyle("#000000");
				ctx.fillText( treelabel, 10, hchunk+2 );
			}
			//console( "leaves " + leaves );
			//double	maxheightold = root.getMaxHeight();
			
			Node mnnode = getMaxNameLength( root, ctx );
			String maxstr = mnnode.getName();
			Node node = equalHeight > 0 ? mnnode : getMaxHeight( root, ctx, ww-30, showleafnames );
			if( node != null ) {
				double gh = getHeight(node);
				String name = node.getName();
				//if( node.getMeta() != null ) name += " ("+node.getMeta()+")";
				double textwidth = showleafnames ? ctx.measureText(name).getWidth() : 0.0;
				
				double mns = 0.0;
				if( showlinage ) {
					double ml = getMaxInternalNameLength( root, ctx );
					mns = ml+30;
				}
				double addon = mns;
				
				double maxheight = 0.0;
				if( circular ) maxheight = equalHeight > 0 ? ((ww-30)*circularScale-(textwidth)*2.0) : (gh*(ww-30)*circularScale)/((ww-60)*circularScale-(textwidth+mns)*2.0);
				else maxheight = equalHeight > 0 ? (ww-30-textwidth) : (gh*(ww-30))/(ww-60-textwidth-mns);
				
				if( equalHeight > 0 ) dw = maxheight/levels;
				
				if( vertical ) {
					//drawFramesRecursive( ctx, root, 0, treelabel == null ? 0 : hchunk*2, startx, Treedraw.this.h/2, equalHeight, false, vertical, maxheight, 0, addon );
					ci = 0;
					if( center ) drawTreeRecursiveCenter( ctx, root, 0, treelabel == null ? 0 : hchunk*2, startx, Treedraw.this.h/2, equalHeight, false, vertical, maxheight, addon, maxstr );
					else drawTreeRecursive( ctx, root, 0, treelabel == null ? 0 : hchunk*2, startx, Treedraw.this.h/2, equalHeight, false, vertical, maxheight, addon, maxstr );
				} else {
					drawFramesRecursive( ctx, root, 0, 0, Treedraw.this.w/2, starty, equalHeight, false, vertical, maxheight, 0, addon );
					ci = 0;
					if( center ) drawTreeRecursiveCenter( ctx, root, 0, 0, Treedraw.this.w/2, starty, equalHeight, false, vertical, maxheight, addon, maxstr );
					else drawTreeRecursive( ctx, root, 0, 0, Treedraw.this.w/2, starty, equalHeight, false, vertical, maxheight, addon, maxstr );
				}
				
				if( showscale ) {
					Node n = getMaxHeight( root, ctx, ww, false );
					double h = n.getHeight();
					double wh = n.getCanvasX()-10;
					double ch = canvas.getCoordinateSpaceHeight();
					
					double nh = pow( 10.0, floor( log10( h/5.0 ) ) );
					double nwh = wh*nh/h;
					
					ctx.beginPath();
					ctx.moveTo(10, ch );
					ctx.lineTo(10, ch-5 );
					ctx.lineTo(10+nwh, ch-5 );
					ctx.lineTo(10+nwh, ch );
					ctx.stroke();
					ctx.closePath();
					String htext = nh.toString();
					double sw = ctx.measureText( htext ).getWidth();
					ctx.fillText( htext, 10+(nwh-sw)/2.0, ch-8 );
				}
			}
		}
	}

  void handleTree() {
		//this.treeutil = treeutil;
		//treeutil.getNode().countLeaves()
		
		Node n = treeutil.getNode();
		if( n != null ) {
			root = n;
			drawTree( treeutil );
		}
	}

  void setTreeUtil( TreeUtil tu, String val ) {
		//if( this.treeutil != null ) console( "batjong2 " + val );
		//else console( "batjong2333333333333333333333333333333333333333333333333333 " + val );
		this.treeutil = tu;
	}

  void setNode( Node n ) {
		//if( n == null ) console( "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeermmmmmmmmmmmmmmmmmmmmmmmmmmm" );
		//else console( "fjorulalli " + n.toString() );
		//if( n.toString().indexOf("bow_data") == -1 ) 
    treeutil.setNode( n );
	}

  List<Sequence> currentSeqs = null;
	void handleText( String str ) {
		//Browser.getWindow().getConsole().log("erm " + str);
		if( str != null && str.length > 1 && !str.startsWith("{") && !str.startsWith("\"") && !str.startsWith("!") ) {
			List<Sequence> seqs = currentSeqs;
			currentSeqs = null;
			//TreeUtil	treeutil;
			
			//elemental.html.Window wnd = Browser.getWindow();
			//Console cnsl = wnd.getConsole();
			/*if( cnsl != null ) {
				cnsl.log( "eitthvad i gangi" );
			}*/
			
			if( str.startsWith("propogate") ) {
				/*if( cnsl != null ) {
					cnsl.log( str );
				}*/
				
				int iof = str.indexOf('{');
				int eof = str.indexOf('}', iof+1);
				List<String> split = str.substring(iof+1, eof).split(",");
				if( treeutil.getNode() != null ) {
					treeutil.propogateSelection( Set.of(split), treeutil.getNode() );
					handleTree();
				}
			} else if( str.startsWith("#") ) {
				int i = str.lastIndexOf("begin trees");
				if( i != -1 ) {
					i = str.indexOf('(', i);
					int l = str.indexOf(';', i+1);
					
					Map<String,String> namemap = new HashMap<String,String>();
					int t = str.indexOf("translate");
					int n = str.indexOf("\n", t);
					int c = str.indexOf(";", n);
					
					String treelist = str.substring(n+1, c);
					List<String> split = treelist.split(",");
					for( String name in split ) {
						String trim = name.trim();
						int v = trim.indexOf(' ');
						namemap.put( trim.substring(0, v), trim.substring(v+1) );
					}
					
					String tree = str.substring(i, l).replaceAll("[\r\n]+", "");
					TreeUtil treeutil = new TreeUtil();
					treeutil.init( tree, false, null, null, false, null, null, false );
					setTreeUtil( treeutil, tree );
					treeutil.replaceNames( treeutil.getNode(), namemap );
					handleTree();
				}
			} else if( str.startsWith(">") ) {
				//final TreeUtil 
				setTreeUtil( new TreeUtil(), str );
				try {
					final List<Sequence> lseq = importReader( str );
					currentSeqs = lseq;
					
					final DialogBox db = new DialogBox();
					VerticalPanel	dbvp = new VerticalPanel();
					
					final CheckBox ewCheck = new CheckBox("Entropy weighted dist-matrix");
					final CheckBox egCheck = new CheckBox("Exclude gaps");
					final CheckBox btCheck = new CheckBox("Bootstrap");
					final CheckBox ctCheck = new CheckBox("Jukes-cantor");
					
					final RadioButton rb = new RadioButton("Parsimony insertion", "parseChoice");
					if( seqs != null && seqs.get(0).getLength() == currentSeqs.get(0).getLength() ) {
						final RadioButton rb2 = new RadioButton("New tree", "parseChoice");
						
						rb2.addClickHandler( new ClickHandler() {
							@Override
							public void onClick(ClickEvent event) {
								if( !rb2.getValue() ) {
									ewCheck.setEnabled( false );
									egCheck.setEnabled( false );
									btCheck.setEnabled( false );
									ctCheck.setEnabled( false );
								} else {
									ewCheck.setEnabled( true );
									egCheck.setEnabled( true );
									btCheck.setEnabled( true );
									ctCheck.setEnabled( true );
								}
							}
						});
						
						dbvp.add( rb );
						dbvp.add( rb2 );
					}
					ctCheck.setValue( true );
					
					dbvp.add( ewCheck );
					dbvp.add( egCheck );
					dbvp.add( btCheck );
					dbvp.add( ctCheck );
					
					db.setModal( true );
					HorizontalPanel hp = new HorizontalPanel();
					Button closeButton = new Button("Ok");
					closeButton.addClickHandler( new ClickHandler() {
						@Override
						public void onClick(ClickEvent event) {
							db.hide();
						}
					});
					hp.add( closeButton );
					hp.setHorizontalAlignment( HorizontalPanel.ALIGN_CENTER );
					dbvp.add( hp );
					
					db.add( dbvp );
					db.center();
					
					db.addCloseHandler( new CloseHandler<PopupPanel>() {
						@Override
						public void onClose(CloseEvent<PopupPanel> event) {
							if( rb.getValue() ) {
								if( treeutil != null ) {
									
								}
							} else {
								boolean excludeGaps = egCheck.getValue();
								boolean bootstrap = btCheck.getValue();
								boolean cantor = ctCheck.getValue();
								boolean entropyWeight = ewCheck.getValue();
								
								List<Integer>	idxs = null;
								if( excludeGaps ) {
									int start = Integer.MIN_VALUE;
									int end = Integer.MAX_VALUE;
									
									for( Sequence seq : lseq ) {
										if( seq.getRealStart() > start ) start = seq.getRealStart();
										if( seq.getRealStop() < end ) end = seq.getRealStop();
									}
									
									idxs = new ArrayList<Integer>();
									for( int x = start; x < end; x++ ) {
										//int i;
										boolean skip = false;
										for( Sequence seq : lseq ) {
											char c = seq.charAt( x );
											if( c != '-' && c != '.' && c == ' ' ) {
												skip = true;
												break;
											}
										}
										
										if( !skip ) {
											idxs.add( x );
										}
									}
								}
								
								double[]	dvals = new double[ lseq.size()*lseq.size() ];
								double[] ent = null;
								if( entropyWeight ) ent = Sequence.entropy( lseq );
									
									/*if( idxs != null ) {
										int total = idxs.size();
										ent = new double[total];
										Map<Character,Integer>	shanmap = new HashMap<Character,Integer>();
										for( int x = 0; x < total; x++ ) {
											shanmap.clear();
											
											for( Sequence seq : lseq ) {
												char c = seq.charAt( idxs.get(x) );
												int val = 0;
												if( shanmap.containsKey(c) ) val = shanmap.get(c);
												shanmap.put( c, val+1 );
											}
											
											double res = 0.0;
											for( char c : shanmap.keySet() ) {
												int val = shanmap.get(c);
												double p = (double)val/(double)lseq.size();
												res -= p*Math.log(p);
											}
											ent[x] = res/Math.log(2.0);
										}
									} else {
										
									}
									}*/
							
								Sequence.distanceMatrixNumeric(lseq, dvals, idxs, false, cantor, ent);
								
								List<String>	names = new ArrayList<String>();
								for( Sequence seq : lseq ) {
									names.add( seq.getName() );
								}
								Node n = treeutil.neighborJoin( dvals, names, null, true );
								
								if( bootstrap ) {
									Comparator<Node>	comp = new Comparator<TreeUtil.Node>() {
										@Override
										public int compare(Node o1, Node o2) {
											String c1 = o1.toStringWoLengths();
											String c2 = o2.toStringWoLengths();
											
											return c1.compareTo( c2 );
										}
									};
									treeutil.arrange( n, comp );
									String tree = n.toStringWoLengths();
									
									for( int i = 0; i < 100; i++ ) {
										Sequence.distanceMatrixNumeric( lseq, dvals, idxs, true, cantor, ent );
										Node nn = treeutil.neighborJoin(dvals, names, null, true);
										treeutil.arrange( nn, comp );
										treeutil.compareTrees( tree, n, nn );
										
										//String btree = nn.toStringWoLengths();
										//System.err.println( btree );
									}
									treeutil.appendCompare( n );
								}
								setNode( n );
								handleTree();
							}
						}
					});
				} on Exception {
					//e.printStackTrace();
				}
			} else if( str.startsWith("[") ) {
				int k = str.indexOf(']');
				int i = str.indexOf('(', k+1);
				if( i != -1 ) {
					String treestr = str.substring(i);
					String tree = treestr.replaceAll("[\r\n]+", "");
					TreeUtil treeutil = new TreeUtil();
					treeutil.init( tree, false, null, null, false, null, null, false );
					
					setTreeUtil( treeutil, str );
					handleTree();
				}
			} else if( !str.startsWith("(") ) {
				setTreeUtil( new TreeUtil(), str );
				List<String> names;
				List<double> dvals;
				int len;
				
				bool b = false;				
				if( str.startsWith(" ") || str.startsWith("\t") ) {
					names = [];
					final List<String> lines = str.split("\n");
					len = int.parse( lines[0].trim() );
					dvals = parseDistance( len, lines, names );
					
					if( root != null && len == root.countLeaves() ) {
						b = true;
						
						final DialogBox db = new DialogBox( false, true );
						db.setModal( true );
						db.getElement().getStyle().setBackgroundColor( "#EEEEEE" );
						//db.setSize("400px", "300px");
						VerticalPanel	vp = new VerticalPanel();
						vp.add( new Label("Apply distances to existing tree?") );
						HorizontalPanel hp = new HorizontalPanel();
						
						Button	yesb = new Button("Yes");
						Button nob = new Button("No");
						yesb.addClickHandler( new ClickHandler() {
							@Override
							public void onClick(ClickEvent event) {
								Node n = treeutil.neighborJoin( dvals, names, root, true );
								setNode( n );
								handleTree();
								
								db.hide();
							}
						});
						nob.addClickHandler( new ClickHandler() {
							@Override
							public void onClick(ClickEvent event) {
								Node n = treeutil.neighborJoin( dvals, names, null, true );
								setNode( n );
								handleTree();
								
								db.hide();
							}
						});
						
						hp.add( yesb );
						hp.add( nob );
						vp.add( hp );
						db.add( vp );
						db.center();
					}
				} else {
					String[] lines = str.split("\n");
					names = Arrays.asList( lines[0].split("\t") );
					len = names.size();
					dvals = new double[len*len];
					for( int i = 1; i < lines.length; i++ ) {
						String[] ddstrs = lines[i].split("\t");
						if( ddstrs.length > 1 ) {
							int k = 0;
							for( String ddstr : ddstrs ) {
								dvals[(i-1)*len+(k++)] = Double.parseDouble(ddstr);
							}
						}
					}
				}
				
				if( !b ) {
					Node n = treeutil.neighborJoin( dvals, names, null, true );
					setNode( n );
					//console( treeutil.getNode().toString() );
					handleTree();
				}
			} else {
				//Browser.getWindow().getConsole().log("what");
				String tree = str.replaceAll("[\r\n]+", "");
				TreeUtil	treeutil =  new TreeUtil();
				treeutil.init( tree, false, null, null, false, null, null, false );
				setTreeUtil( treeutil, str );
				handleTree();
			}
		}
	}
}