import 'sequence.dart';
import 'treeutil.dart';
import 'node.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class TreeDraw {
  TreeUtil	treeutil;
  Node root;
  List<Node> nodearray;

  double w;
	double h;
	double dw;
	double dh;

  int				  ci = 0;

  bool				center = false;
	int					equalHeight = 0;
	bool				showscale = true;
	bool				showbubble = false;
	bool				showlinage = false;
	bool				showleafnames = true;
	bool  			rightalign = false;
	bool				circular = false;
	bool				radial = false;

  double log10(double x) {
    return log(x) / log(10);
  }


  int count = 0;
	double spread = 0.0;
	List<double> bounds = List.filled(4, 0.0);
	List<double> lbounds = List.filled(4, 0.0);
  List<double> constructNode(Canvas canvas, TreeUtil tree, Node node, double angleStart,
			double angleFinish, double xPosition, double yPosition,
			double length, bool nodraw) {
		final double branchAngle = (angleStart + angleFinish) / 2.0;

		final double directionX = cos(branchAngle);
		final double directionY = sin(branchAngle);
		List<double> nodePoint = [xPosition + (length * directionX), yPosition + (length * directionY)];
		
		double x0 = nodePoint[0];
		double y0 = nodePoint[1];

		if( !node.isLeaf() ) {
		//if (!tree.isExternal(node)) {

			// Not too clear how to do hilighting for radial trees so leave it
			// out...
			// if (hilightAttributeName != null &&
			// node.getAttribute(hilightAttributeName) != null) {
			// constructHilight(tree, node, angleStart, angleFinish, xPosition,
			// yPosition, length, cache);
			// }

			//node.get
			List<Node> children = node.getNodes(); //tree.getChildren(node);
			List<int> leafCounts = List.filled(children.length, 0);
			int sumLeafCount = 0;

			int i = 0;
			for (Node child in children) {
				leafCounts[i] = child.countLeaves(); //jebl.evolution.trees.Utils.getExternalNodeCount(tree, child);
				sumLeafCount += leafCounts[i];
				i++;
			}
			
			//Browser.getWindow().getConsole().log( "s " + sumLeafCount );

			double span = (angleFinish - angleStart);

			if( !node.isRoot() ) {
			//if (!tree.isRoot(node)) {
				span *= 1.0 + (spread / 10.0);
				angleStart = branchAngle - (span / 2.0);
				angleFinish = branchAngle + (span / 2.0);
			}

			double a2 = angleStart;

			//Browser.getWindow().getConsole().log( "erm " + angleStart + "  " + angleFinish );
			
			bool rotate = false;
			/*if (node.getAttribute("!rotate") != null && ((Boolean) node.getAttribute("!rotate"))) {
				rotate = true;
			}*/
			for (i = 0; i < children.length; ++i) {
				int index = i;
				if (rotate) {
					index = children.length - i - 1;
				}

				Node child = children[index];

				final double childLength = child.getLength();
				double a1 = a2;
				a2 = a1 + (span * leafCounts[index] / sumLeafCount);
				List<double> childPoint = constructNode( canvas, tree, child, a1, a2, nodePoint[0], nodePoint[1], childLength, nodraw);
				double x1 = childPoint[0];
				double y1 = childPoint[1];
				//Line2D branchLine = new Line2D.Double(childPoint.getX(), childPoint.getY(), nodePoint.getX(), nodePoint.getY());

				List<num> colouring = null;//new Object[] {}; //null;
				/*if (branchColouringAttribute != null) {
					colouring = (Object[]) child.getAttribute(branchColouringAttribute);
				}*/
				if (colouring != null) {
					// If there is a colouring, then we break the path up into
					// segments. This should allow use to iterate along the
					// segments
					// and colour them as we draw them.

					//double nodeHeight = tree.getHeight(node);
					//double childHeight = tree.getHeight(child);
					//GeneralPath branchPath = new GeneralPath();

					// to help this, we are going to draw the branch backwards

          Path path = Path();
					path.moveTo(x1, y1);
					double interval = 0.0;
					for (int j = 0; j < colouring.length - 1; j += 2) {
						// float height = ((Number)colouring[j+1]).floatValue();
						// float p = (height - childHeight) / (nodeHeight -
						// childHeight);
						interval += colouring[j + 1];
						double p = interval / childLength; //(nodeHeight - childHeight);
						double x = x1 + ((x0 - x1) * p);
						double y = y1 + ((y0 - y1) * p);
						path.lineTo(x, y);
					}
					path.lineTo(x0, y0);
					path.close();
					
          Paint paint = Paint();
          paint.style = PaintingStyle.stroke;

          canvas.drawPath(path, paint);

					// add the branchPath to the map of branch paths
					//cache.branchPaths.put(child, branchPath);

				} else {
					// add the branchLine to the map of branch paths
					//cache.branchPaths.put(child, branchLine);
					if( nodraw ) {
						if( x1 < bounds[0] ) bounds[0] = x1;
						if( x1 > bounds[2] ) bounds[2] = x1;
						if( y1 < bounds[1] ) bounds[1] = y1;
						if( y1 > bounds[3] ) bounds[3] = y1;
						
						if( x0 < bounds[0] ) bounds[0] = x0;
						if( x0 > bounds[2] ) bounds[2] = x0;
						if( y0 < bounds[1] ) bounds[1] = y0;
						if( y0 > bounds[3] ) bounds[3] = y0;
					} else {
						double xscale = (canvas.getCoordinateSpaceWidth()-10.0-(lbounds[2]-lbounds[0]))/(bounds[2]-bounds[0]);
						//double yscale = (canvas.getCoordinateSpaceHeight()-10.0-(lbounds[3]-lbounds[1]))/(bounds[3]-bounds[1]);
						//double scale = Math.min(xscale, yscale);
						double xoffset = 5.0-lbounds[0]-bounds[0]*xscale;
						double yoffset = 5.0-lbounds[1]-bounds[1]*xscale;
						
						double xx1 = xscale*x1 + xoffset;
						double yy1 = xscale*y1 + yoffset;
						
						double xx2 = xscale*x0 + xoffset;
						double yy2 = xscale*y0 + yoffset;
						
            Path path = Path();
						path.moveTo(xx1,yy1);
						path.lineTo(xx2,yy2);
						path.close();
						
            Paint paint = Paint();
            paint.style = PaintingStyle.stroke;
            paint.color = Color(0xff000000);
            canvas.drawPath(path, paint);
					}
				}

				//cache.branchLabelPaths.put(child, (Line2D) branchLine.clone());
			}

			/*double[] nodeLabelPoint = new double[] { xPosition
					+ ((length + 1.0) * directionX), yPosition
					+ ((length + 1.0) * directionY) };

			Line2D nodeLabelPath = new Line2D.Double(nodePoint, nodeLabelPoint);
			cache.nodeLabelPaths.put(node, nodeLabelPath);*
			
			double x1 = 100.0*nodePoint[0] + 300.0;
			double y1 = 100.0*nodePoint[1] + 300.0;
			
			double x2 = 100.0*nodeLabelPoint[0] + 300.0;
			double y2 = 100.0*nodeLabelPoint[1] + 300.0;
			
			ctx.setStrokeStyle("#00FF00");
			ctx.beginPath();
			ctx.moveTo(x1,y1);
			ctx.lineTo(x2,y2);
			ctx.closePath();
			ctx.stroke();*/

		} else {
			double x1 = xPosition + ((length + 1.0) * directionX);
			double y1 = yPosition + ((length + 1.0) * directionY);
			
			String name = node.getName();
			bool it = name.contains("<i>");
			name = name.replaceAll("<i>", "").replaceAll("</i>", "");
			
			String fontstr = (node.isSelected() ? "bold" : "")+(it ? " italic " : " ")+(int)(fontscale*log(hchunk))+"px sans-serif";
			if( !fontstr.equals(ctx.getFont()) ) ctx.setFont( fontstr );
			
			if( nodraw ) {
				ctx.setFillStyle("#000000");
				double horn = atan2( y1-y0, x1-x0 );
				
				TextMetrics tm = ctx.measureText( name );
				double strlen = tm.getWidth();
				/*if( Math.abs(horn) > pi/2.0 ) {
					horn += pi;
				}*/
				double x = strlen*cos( horn );
				double y = strlen*sin( horn );
				
				if( x < lbounds[0] ) lbounds[0] = x;
				if( x > lbounds[2] ) lbounds[2] = x;
				if( y < lbounds[1] ) lbounds[1] = y;
				if( y > lbounds[3] ) lbounds[3] = y;
			} else {
				ctx.setFillStyle("#000000");
				
				double xscale = (canvas.getCoordinateSpaceWidth()-10.0-(lbounds[2]-lbounds[0]))/(bounds[2]-bounds[0]);
				//double yscale = (canvas.getCoordinateSpaceHeight()-10.0-(lbounds[3]-lbounds[1]))/(bounds[3]-bounds[1]);
				//double scale = Math.min(xscale, yscale);
				double xoffset = 5.0-lbounds[0]-bounds[0]*xscale;
				double yoffset = 5.0-lbounds[1]-bounds[1]*xscale;
				
				double xx1 = xscale*x1 + xoffset;
				double yy1 = xscale*y1 + yoffset;
				
				double xx2 = xscale*x0 + xoffset;
				double yy2 = xscale*y0 + yoffset;
				
				double horn = atan2( y0-y1, x0-x1 );
				
				//TextMetrics tm = ctx.measureText( name );
				//double strlen = name.length*10.0;//.getWidth();
				if( horn.abs() > pi/2.0 ) {
					horn += pi;
					
					canvas.translate(xx2, yy2);
					canvas.rotate( horn );

          TextStyle textStyle = TextStyle(color: Colors.blue[800]);
          TextSpan textSpan = TextSpan(style: textStyle, text: name);
          TextPainter textPainter = TextPainter(text: textSpan, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
          textPainter.layout();
          textPainter.paint(canvas, Offset(3.0, 3.0));
					//ctx.fillText( name, 3.0, 3.0);
					canvas.rotate( -horn );
					canvas.translate(-xx2, -yy2);
				} else {
					canvas.translate(xx2, yy2);
					canvas.rotate( horn );

          TextStyle textStyle = TextStyle(color: Colors.blue[800]);
          TextSpan textSpan = TextSpan(style: textStyle, text: name);
          TextPainter textPainter = TextPainter(text: textSpan, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
          textPainter.layout();
          double strlen = textPainter.width;
          textPainter.paint(canvas, Offset(-strlen-3.0, 3.0));

					//ctx.fillText( name, -strlen-3.0, 3.0 );
					canvas.rotate( -horn );
					canvas.translate(-xx2, -yy2);
				}
			}
			
			/*double[] taxonPoint = new double[] { xPosition + (length + 1.0) * directionX, yPosition + (length + 1.0) * directionY };
			Point2D taxonPoint = new Point2D.Double(xPosition
					+ ((length + 1.0) * directionX), yPosition
					+ ((length + 1.0) * directionY));

			Line2D taxonLabelPath = new Line2D.Double(nodePoint, taxonPoint);
			cache.tipLabelPaths.put(node, taxonLabelPath);*
			
			double x1 = 100.0*nodePoint[0] + 300.0;
			double y1 = 100.0*nodePoint[1] + 300.0;
			
			double x2 = 100.0*taxonPoint[0] + 300.0;
			double y2 = 100.0*taxonPoint[1] + 300.0;
			
			ctx.setStrokeStyle("#0000FF");
			ctx.beginPath();
			ctx.moveTo(x1,y1);
			ctx.lineTo(x2,y2);
			ctx.closePath();
			ctx.stroke();*/
		}

		/*Point2D nodeShapePoint = new Point2D.Double(xPosition
				+ ((length - 1.0) * directionX), yPosition
				+ ((length - 1.0) * directionY));
		Line2D nodeShapePath = new Line2D.Double(nodePoint, nodeShapePoint);
		cache.nodeShapePaths.put(node, nodeShapePath);

		// add the node point to the map of node points
		cache.nodePoints.put(node, nodePoint);*
		
		double[] nodeShapePoint = new double[] {xPosition + (length - 1.0) * directionX, yPosition + (length - 1.0) * directionY };
		
		double x1 = 100.0*nodePoint[0] + 300.0;
		double y1 = 100.0*nodePoint[1] + 300.0;
		
		double x2 = 100.0*nodeShapePoint[0] + 300.0;
		double y2 = 100.0*nodeShapePoint[1] + 300.0;
		
		ctx.setStrokeStyle("#FFFF00");
		ctx.beginPath();
		ctx.moveTo(x1,y1);
		ctx.lineTo(x2,y2);
		ctx.closePath();
		ctx.stroke();*/

		return nodePoint;
	}

  double fontscale = 5.0;
	double hchunk = 10.0;
	void drawTree( Canvas canvas, TreeUtil treeutil ) {
		int ww = getClientWidth();
		if( radial ) {
			if( treeutil != null ) {
				Node root = treeutil.getNode();
				//Browser.getWindow().getConsole().log("heyhey");
				count = 0;
				
				//Context2d ctx = canvas.getContext2d();
				
				bounds[0] = double.maxFinite;
				bounds[1] = double.maxFinite;
				bounds[2] = double.negativeInfinity;
				bounds[3] = double.negativeInfinity;
				
				lbounds[0] = double.maxFinite;
				lbounds[1] = double.maxFinite;
				lbounds[2] = double.negativeInfinity;
				lbounds[3] = double.negativeInfinity;
				
				constructNode( canvas, treeutil, root, 0.0, pi * 2, 0.0, 0.0, 0.0, true );
				
				double xscale = (canvas.getCoordinateSpaceWidth()-10.0-(lbounds[2]-lbounds[0]))/(bounds[2]-bounds[0]);
				//double yscale = (canvas.getCoordinateSpaceHeight()-10.0-(lbounds[3]-lbounds[1]))/(bounds[3]-bounds[1]);
				//double scale = Math.min(xscale, yscale);
				double xoffset = 5.0-lbounds[0]-bounds[0]*xscale;
				double yoffset = 5.0-lbounds[1]-bounds[1]*xscale;
				
				int hval = ((bounds[3]-bounds[1])*xscale+(lbounds[3]-lbounds[1])+10) as int;
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
				constructNode( canvas, treeutil, root, 0.0, pi * 2, 0.0, 0.0, 0.0, false );
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
			
			int hsize = hchunk*leaves as int;
			if( treelabel != null ) hsize += 2*hchunk as int;
			if( showscale ) hsize += 2*hchunk as int;
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
			
			double starty = 10; //h/25;
			double startx = 10; //w/25;
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
				String fontstr = ((fontscale*log(hchunk) as int).toString()+"px sans-serif";
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
					if( center ) drawTreeRecursiveCenter( ctx, root, 0, treelabel == null ? 0 : hchunk*2, startx, h/2, equalHeight, false, vertical, maxheight, addon, maxstr );
					else drawTreeRecursive( ctx, root, 0, treelabel == null ? 0 : hchunk*2, startx, h/2, equalHeight, false, vertical, maxheight, addon, maxstr );
				} else {
					drawFramesRecursive( ctx, root, 0, 0, w/2, starty, equalHeight, false, vertical, maxheight, 0, addon );
					ci = 0;
					if( center ) drawTreeRecursiveCenter( ctx, root, 0, 0, w/2, starty, equalHeight, false, vertical, maxheight, addon, maxstr );
					else drawTreeRecursive( ctx, root, 0, 0, w/2, starty, equalHeight, false, vertical, maxheight, addon, maxstr );
				}
				
				if( showscale ) {
					Node n = getMaxHeight( root, ctx, ww, false );
					double h = n.getHeight();
					double wh = n.getCanvasX()-10;
					double ch = canvas.getCoordinateSpaceHeight();
					
					double nh = pow( 10.0, log10( h/5.0 ) ).floorToDouble();
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

  void drawFramesRecursive( Canvas g2, Node node, double x, double y, double startx, double starty, int equalHeight, bool noAddHeight, bool vertical, double maxheight, int leaves, double addon ) {		
		if( node.getNodes().length > 0 ) {			
			int total = 0;
			int sc = node.getColorInt();
			if( sc != null ) {// paint && !(allNull || nullNodes) ) {
				//g2.setPaint( sc );
				//g2.setFillStyle( sc );
        Paint paint = Paint();
        paint.style = PaintingStyle.fill;
        paint.color = Color(sc);
				
				int k = 12;//(int)(w/32);
				if( vertical ) {
					double xoff = startx-(1*k)/4;
          Rect rect = Rect.fromLTWH(xoff, y+k/4-1, w-xoff-w/17, dh*leaves);
					g2.drawRect( rect, paint ); //ny-yoff );
				} else {
					double yoff = starty-(1*k)/4;
          Rect rect = Rect.fromLTWH((x+k/4), yoff, dw*total-k/2.0, h-yoff-h/17);
					g2.drawRect( rect, paint ); //ny-yoff );
				}
				//g2.setPaint( oldPaint );
			}
			
			for( Node resnode in node.getNodes() ) {
				int nleaves = resnode.countLeaves();
				int nlevels = resnode.countMaxHeight();
				int mleaves = max(1, nleaves);
				
				double nx = 0;
				double ny = 0;
				
				if( vertical ) {
					//minh = 0.0;
					ny = dh*total+(dh*mleaves)/2.0;
					if( equalHeight > 0 ) {
						nx = w/25.0+dw*(w/dw-nlevels);
					} else {
						nx = /*h/25+*/startx+(w*resnode.geth())/(maxheight*1.1);
						//ny = 100+(int)(/*starty+*/(h*(node.h+resnode.h-minh))/((maxh-minh)*3.2));
					}

					if( nleaves == 0 ) {
						int v = (nodearray.length*(y+ny))/canvas.getCoordinateSpaceHeight() as int;
						//console( nodearray.length + "  " + canvas.getCoordinateSpaceHeight() + "  " + v );
						if( v >= 0 && v < nodearray.length ) nodearray[v] = resnode;
					}
				} else {
					//minh = 0.0;
					nx = dw*total+(dw*mleaves)/2.0;
					if( equalHeight > 0 ) {	
						ny = h/25.0+dh*(h/dh-nlevels);
					} else {
						ny = /*h/25+*/starty+(h*resnode.geth())/(maxheight*2.2);
						//ny = 100+(int)(/*starty+*/(h*(node.h+resnode.h-minh))/((maxh-minh)*3.2));
					}
				}
				int k = 12;//(int)(w/32);
				
				String use = resnode.getName() == null || resnode.getName().length == 0 ? resnode.getMeta() : resnode.getName();
				bool nullNodes = resnode.getNodes() == null || resnode.getNodes().length == 0;
				bool paint = use != null && use.length > 0;
				
				/*ci++;
				for( int i = colors.size(); i <= ci; i++ ) {
					colors.add( "rgb( "+(int)(rnd.nextFloat()*255)+", "+(int)(rnd.nextFloat()*255)+", "+(int)(rnd.nextFloat()*255)+" )" );
				}*/
				//String color = node.getColor(); //colors.get(ci);
				
				/*if( resnode.color != null ) {
					color = resnode.color;
				}
				GradientPaint shadeColor = createGradient(color, (int)(ny-k/2), (int)h);*/
				
				if( vertical ) {
					//drawFramesRecursive( g2, resnode, x+dw*total, y+h, (dw*nleaves)/2.0, ny, paint ? shadeColor : null, nleaves, equalHeight );
					drawFramesRecursive( g2, resnode, x+w, y+dh*total, nx, (dh*mleaves)/2.0, equalHeight, noAddHeight, vertical, maxheight, mleaves, addon );
				} else {
					//drawFramesRecursive( g2, resnode, x+dw*total, y+h, (dw*nleaves)/2.0, ny, paint ? shadeColor : null, nleaves, equalHeight );
					drawFramesRecursive( g2, resnode, x+dw*total, y+h, (dw*mleaves)/2.0, /*noAddHeight?starty:*/ny, equalHeight, noAddHeight, vertical, maxheight, mleaves, addon );
				}
				
				//drawFramesRecursive( g2, resnode, x+dw*total, y+h, (dw*nleaves)/2.0, ny, paint ? shadeColor : null, nleaves, equalHeight );
				total += nleaves;
			}
		}
	}
	
	Node getNodeRecursive( Node root, double x, double y ) {
		return null;
	}

  int neveragain = 0;
	double circularScale = 0.9;
	void paintTree( Canvas g2, Node resnode, bool vertical, double x, double y, double nx, double ny, double addon, int mleaves, double realny, String maxstr ) {
		//int k = 12;//w/32;
		int fontSize = 10;
		
		String use = resnode.getName();// == null || resnode.getName().length() == 0 ? resnode.getMeta() : resnode.getName();
		use = resnode.isCollapsed() ? resnode.getCollapsedString() : use;
		bool nullNodes = resnode.isCollapsed() || resnode.getNodes() == null || resnode.getNodes().length == 0;
		bool paint = (use != null && use.length > 0) || (resnode.getMeta() != null && resnode.getMeta().length > 0);
		
		if( paint ) {
			String color = resnode.getColor(); // == null ? "#FFFFFF" : resnode.getColor();
			
			double mhchunk = max( 10.0, hchunk );
			//double strw = 0;
			double strh = fontscale*log(mhchunk);
			double nstrh = resnode.getFontSize() == -1.0 ? strh : resnode.getFontSize()*strh;
			double frmh = strh;
			frmh = resnode.getFontSize() == -1.0 ? frmh : resnode.getFrameSize()*frmh;
			double frmo = resnode.getFrameOffset();
			
			if( nullNodes ) {
				if( showleafnames ) {
					g2.setFillStyle( "#000000" );
					//g2.setFont( bFont );
					
					String name = resnode.getName();
					/*if( resnode.getMeta() != null ) {
						String meta = resnode.getMeta();
						name += " ("+meta+")";
						
						*if( meta.contains("T.ign") ) {
							System.err.println();
						}*
					}*/
					
					List<String> split;
					if( name == null || name.length == 0 && resnode.getCollapsedString() != null ) split = resnode.getCollapsedString().split("_");
					else split = [name]; //name.split("_");
					
					int t = 0;
					//double mstrw = 0;
					//double mstrh = strh;
					//double fontscale = resnode.getFontSize();
					//if( fontscale != -1.0 ) strh *= fontscale;
					
					String fontstr = (resnode.isSelected() ? "bold " : " ")+nstrh.toString()+"px sans-serif";
					if( !fontstr.equals(g2.getFont()) ) g2.setFont( fontstr );
					
					if( !vertical ) {
						for( String str in split ) {
							TextMetrics tm = g2.measureText( str );
							double strw = tm.getWidth();
							//mstrw = max( mstrw, strw );
							/*if( resnode.getColor() != null ) {
								g2.setFillStyle( resnode.getColor() );
								g2.fillRect( (int)(x+nx-strw/2.0), (int)(ny+4+10+(t++)*fontSize), strw, mstrh);
								g2.setFillStyle( "#000000" );
							}*/
							g2.fillText(str, (int)(x+nx-strw/2.0), (int)(ny+4+10+(t++)*fontSize) );
						}
					} else {
						for( String str in split ) {
							bool it = false;
							bool sub = false;
							bool sup = false;
							List<int> li = [];
							int start = 0;
							List<String> tags = ["<i>", "<sub>", "<sup>", "</i>", "</sub>", "</sup>"];
							double pos = 0.0;
							
							while( start < str.length ) {
								li.clear();
								
								for( String tag in tags ) {
									int ti = str.indexOf(tag, start);
									if( ti == -1 ) ti = str.length;
									
									li.add( ti );
								}
								
								double nnstrh = ( ( (sup || sub) ? 3.0 : 5.0 )*nstrh/5.0 );
								double nfrmh = ( ( (sup || sub) ? 3.0 : 5.0 )*frmh/5.0 );
								//if( fontscale != -1.0 ) nnstrh *= fontscale;
								fontstr = (resnode.isSelected() ? "bold" : "")+(it ? " italic " : " ")+nnstrh.toString()+"px sans-serif";
								if( !fontstr.equals(g2.getFont()) ) g2.setFont( fontstr );
								
								double maxstrw = g2.measureText( maxstr ).getWidth();
								
								int minval = li.reduce(min);
								if( minval < str.length ) {
									int mini = li.indexOf( minval );
									String tag = tags[mini];
									
									String substr = str.substring(start, minval);
									double lx = nx+4.0+10.0+(t)*fontSize+pos;
									double ly = y+ny;
									if( circular ) {
										double a = (2.0*pi*ly)/h;
										double val = rightalign ? w-addon+10 : lx;
										double cx = (w+val*circularScale*cos( a ))/2.0;
										double cy = (w+val*circularScale*sin( a ))/2.0;
										
										TextMetrics tm = g2.measureText( substr );
										double strw = tm.getWidth();
										if( a > pi/2.0 && a < 3.0*pi/2.0 ) {
											//u += 0.5*total;
											g2.translate( cx, cy );
											g2.rotate( a+pi );
											if( !showbubble && resnode.getColor() != null ) {
												g2.setFillStyle( resnode.getColor() );
												g2.fillRect( -7+(t++)*fontSize  - (rightalign ? 0.0 : strw), nfrmh/2.0-nfrmh+1.0, (rightalign ? maxstrw : strw) + 15, nfrmh*1.15 );
												g2.setFillStyle( "#000000" );
											}
											g2.fillText( substr, rightalign ? 0.0 : -strw, strh/2.0 );
											g2.rotate( -a-pi );
											g2.translate( -cx, -cy );
											
											List<String> infoList = resnode.getInfoList();
											if( infoList != null ) {
												val += strw;
												for( int i = 0; i < infoList.length; i+=2 ) {
													cx = (w+val*circularScale*cos( a ))/2.0;
													cy = (w+val*circularScale*sin( a ))/2.0;
													
													String sstr = infoList[i];
													tm = g2.measureText( sstr );
													strw = tm.getWidth();
													
													g2.translate( cx, cy );
													g2.rotate( a+pi );
													if( i+1 < infoList.length && !showbubble ) {
														String colorstr = infoList[i+1];
														g2.setFillStyle( colorstr.substring( 1, colorstr.length-1 ) );
														g2.fillRect( -7+(t++)*fontSize  - (rightalign ? 0.0 : strw), nfrmh/2.0-nfrmh+1.0, (rightalign ? maxstrw : strw) + 15, nfrmh*1.15 );
														g2.setFillStyle( "#000000" );
													}
													g2.fillText( sstr, rightalign ? 0.0 : -strw, strh/2.0 );
													g2.rotate( -a-pi );
													g2.translate( -cx, -cy );
												
													val += strw;
												}
											}
										} else {
											g2.translate( cx, cy );
											g2.rotate( a );
											if( !showbubble && resnode.getColor() != null ) {
												g2.setFillStyle( resnode.getColor() );
												g2.fillRect( -7+(t++)*fontSize - (rightalign ? maxstrw : 0.0), nfrmh/2.0-nfrmh+1.0, (rightalign ? maxstrw : strw) + 15, nfrmh*1.15 );
												g2.setFillStyle( "#000000" );
											}
											g2.fillText( substr, rightalign ? -strw : 0.0, nnstrh/2.0 );
											g2.rotate( -a );
											g2.translate( -cx, -cy );
											
											List<String> infoList = resnode.getInfoList();
											if( infoList != null ) {
												//val += strw;
												for( int i = 0; i < infoList.length; i+=2 ) {
													cx = (w+val*circularScale*cos( a ))/2.0;
													cy = (w+val*circularScale*sin( a ))/2.0;
													
													String sstr = infoList[i];
													tm = g2.measureText( sstr );
													strw = tm.getWidth();
													
													g2.translate( cx, cy );
													g2.rotate( a );
													if( i+1 < infoList.length && !showbubble ) {
														String colorstr = infoList[i+1];
														g2.setFillStyle( colorstr.substring( 1, colorstr.length-1 ) );
														g2.fillRect( -7+(t++)*fontSize - (rightalign ? 0.0 : -strw), nfrmh/2.0-nfrmh+1.0, (rightalign ? strw : strw) + 15, nfrmh*1.15 );
														g2.setFillStyle( "#000000" );
													}
													g2.fillText( sstr, rightalign ? 0.0 : strw, nnstrh/2.0 );
													g2.rotate( -a );
													g2.translate( -cx, -cy );
												
													val += strw;
												}
											}
										}
										
										/*g2.beginPath();
										g2.moveTo(w/2.0, w/2.0);
										g2.lineTo(cx, cy);
										g2.stroke();
										g2.closePath();*/
										
										//g2.fillText(substr, (w+lx*0.8*cos( a ))/2.0, (w+lx*0.8*sin( a ))/2.0 );
									} else {
										if( !showbubble && resnode.getColor() != null ) {
											double strw = g2.measureText( str ).getWidth();
											g2.setFillStyle( resnode.getColor() );
											g2.fillRect( nx+4+10+(t++)*fontSize, y+ny+nnstrh/2.0-nnstrh+1.0, strw+15, nnstrh*1.15);
											g2.setFillStyle( "#000000" );
										}
										
										ly += nnstrh/2.0;
										if( !rightalign ) {
											g2.fillText(substr, lx, ly );
										} else {
											TextMetrics tm = g2.measureText( substr );
											double strw = tm.getWidth();
											g2.fillText(substr, w-addon-strw, ly );
										}
									}
									pos += g2.measureText( substr ).getWidth();
									
									int next = minval+tag.length;
									start = next;
									if( tag.equals("<i>") ) it = true;
									else if( tag.equals("</i>") ) it = false;
									if( tag.equals("<sup>") ) sup = true;
									else if( tag.equals("</sup>") ) sup = false;
									if( tag.equals("<sub>") ) sub = true;
									else if( tag.equals("</sub>") ) sub = false;
								} else {
									//fontstr = (resnode.isSelected() ? "bold" : "")+(it ? " italic " : " ")+(int)( ( (sup || sub) ? 3.0 : 5.0 )*Math.log(hchunk) )+"px sans-serif";
									//if( !fontstr.equals(g2.getFont()) ) g2.setFont( fontstr );
									
									String substr = str.substring(start, str.length);
									
									double lx = nx+4+10+(t)*fontSize+pos;
									double ly = y+ny;
									if( circular ) {
										double a = (2.0*pi*ly)/h;
										double val = rightalign ? w-addon+100 : lx;
										double cx = (w+val*circularScale*cos( a ))/2.0;
										double cy = (w+val*circularScale*sin( a ))/2.0;
										//double cx = (w+val*cos( a ))/2.0;
										//double cy = (w+val*sin( a ))/2.0;
										
										TextMetrics tm = g2.measureText( substr );
										double strw = tm.getWidth();
										if( a > pi/2.0 && a < 3.0*pi/2.0 ) {
											//u += 0.5*total;
											g2.translate( cx, cy );
											g2.rotate( a+pi );
											if( !showbubble && resnode.getColor() != null ) {
												g2.setFillStyle( resnode.getColor() );
												g2.fillRect( -7+(t++)*fontSize  - (rightalign ? 0.0 : strw), nfrmh/2.0-nfrmh+1.0, (rightalign ? maxstrw : strw) + 15, nfrmh*1.15  );
												g2.setFillStyle( "#000000" );
											}
											g2.fillText( substr, rightalign ? 0.0 : -strw, nnstrh/2.0 );
											g2.rotate( -a-pi );
											g2.translate( -cx, -cy );
											
											List<String> infoList = resnode.getInfoList();
											if( infoList != null ) {
												//val += strw;
												for( int i = 0; i < infoList.length; i+=2 ) {
													cx = (w+val*circularScale*cos( a ))/2.0;
													cy = (w+val*circularScale*sin( a ))/2.0;
													
													String sstr = infoList[i];
													tm = g2.measureText( sstr );
													strw = tm.getWidth();
													
													g2.translate( cx, cy );
													g2.rotate( a+pi );
													if( i+1 < infoList.length && !showbubble ) {
														String colorstr = infoList[i+1];
														g2.setFillStyle( colorstr.substring( 1, colorstr.length-1 ) );
														g2.fillRect( -7-(t)*strw  - (rightalign ? strw : 0.0) - 0, nfrmh/2.0-nfrmh+1.0, (rightalign ? strw : strw) + 10, nfrmh*1.15 );
														g2.setFillStyle( "#000000" );
													}
													g2.fillText( sstr, -7-(t)*strw + (rightalign ? -strw : 0.0) + 5, strh/2.0 );
													g2.rotate( -a-pi );
													g2.translate( -cx, -cy );
												
													t++;
													val += strw;
													
													//break;
												}
											}
										} else {
											g2.translate( cx, cy );
											g2.rotate( a );
											if( !showbubble && resnode.getColor() != null ) {
												g2.setFillStyle( resnode.getColor() );
												g2.fillRect(-7+(t++)*fontSize  - (rightalign ? maxstrw : 0.0), nfrmh/2.0-nfrmh+1.0, (rightalign ? maxstrw : strw) + 15, nfrmh*1.15  );
												g2.setFillStyle( "#000000" );
											}
											g2.fillText( substr, rightalign ? -strw : 0.0, nnstrh/2.0 );
											g2.rotate( -a );
											g2.translate( -cx, -cy );
											
											List<String> infoList = resnode.getInfoList();
											//for( String info : infoList ) console( info );
											if( infoList != null ) {
												double tstrw = strw;
												//val += strw;
												for( int i = 0; i < infoList.length; i+=2 ) {
													cx = (w+val*circularScale*cos( a ))/2.0;
													cy = (w+val*circularScale*sin( a ))/2.0;
													
													String sstr = infoList[i];
													tm = g2.measureText( sstr );
													strw = tm.getWidth();
													tstrw += strw;
													
													g2.translate( cx, cy );
													g2.rotate( a );
													if( i+1 < infoList.length && !showbubble ) {
														String colorstr = infoList[i+1];
														g2.setFillStyle( colorstr.substring( 1, colorstr.length-1 ) );
														g2.fillRect( -7+(t)*strw - (rightalign ? 0.0 : strw) + 5, nfrmh/2.0-nfrmh+1.0, (rightalign ? strw : strw) + 10, nfrmh*1.15 );
														g2.setFillStyle( "#000000" );
													}
													g2.fillText( sstr, -7+(t)*strw + (rightalign ? 0.0 : strw) + 10, nnstrh/2.0 );
													g2.rotate( -a );
													g2.translate( -cx, -cy );
												
													t++;
													val += strw;
													
													//break;
												}
											}
										}
										
										//double a = (2.0*pi*ly)/h;
										//g2.fillText(substr, (w+lx*0.8*cos( a ))/2.0, (w+lx*0.8*sin( a ))/2.0 );
									} else {
										if( !showbubble && resnode.getColor() != null ) {
											double strw = g2.measureText( str ).getWidth();
											g2.setFillStyle( resnode.getColor() );
											g2.fillRect( nx+4+10+(t++)*fontSize, y+ny+nnstrh/2.0-nnstrh+1.0, strw+15, nnstrh*1.15);
											g2.setFillStyle( "#000000" );
										}
										
										ly += nnstrh/2.0;
										if( !rightalign ) {
											g2.fillText(substr, lx, ly );
										} else {
											TextMetrics tm = g2.measureText( substr );
											double strw = tm.getWidth();
											g2.fillText(substr, w-addon-strw, ly );
										}
									}
									start = str.length;
								}
							
							}
						}
					}
					
					/*int x1 = (int)(x+nx-mstrw/2);
					int x2 = (int)(x+nx+mstrw/2);
					int y1 = (int)(ny+4+h/25+(-1)*bFont.getSize());
					int y2 = (int)(ny+4+h/25+(split.length-1)*bFont.getSize());
					yaml += resnode.name + ": [" + x1 + "," + y1 + "," + x2 + "," + y2 + "]\n";*/
					
					//if( neveragain < 450 ) {
						drawSingleMundi( vertical, use, g2, resnode, color, frmh, frmo, y, realny, mleaves, addon, strh, nstrh );
						//neveragain++;
					//}
				}
			} else {
				bool b = use.length > 2;
				
				if( color != null && color.length > 0 ) g2.setFillStyle( color );
				else g2.setFillStyle( "#000000" );
				
				String fontstr = (resnode.isSelected() ? "bold " : " ")+nstrh.toString()+"px sans-serif";
				if( !fontstr.equals(g2.getFont()) ) g2.setFont( fontstr );
				//String[] split = use.split( "_" );
				TextMetrics tm;
				double strw = 0.0;
				if( b ) {
					//g2.setFont( lFont );
					//for( String s : split ) {
					tm = g2.measureText( use );
					strw = max( strw, tm.getWidth() );
					//}
				} else {
					//g2.setFont( bFont );
					//for( String s : split ) {
						//strw = max( strw, g2.measureText( use ).getWidth() );
					//}
					tm = g2.measureText( use );
					strw = max( strw, tm.getWidth() );
				}
				
				//double strh = max( 10.0, hchunk );//10;
				
				if( !showlinage ) {
					if( color != null && color.length > 0 ) { 
						g2.setFillStyle( color );
					
						if( vertical ) {
							if( circular ) {
								double a = 2.0*pi*(y+ny)/h;
								double cx = (w+nx*circularScale*cos(a))/2.0;
								double cy = (w+nx*circularScale*sin(a))/2.0;
								g2.translate( cx, cy );
								g2.rotate( a );
								if( color != null && color.length > 0 ) g2.fillRect( -(5*strw)/8, -(5*strh)/8, (5*strw)/4, strh*1.2 );
								else {
									g2.setStrokeStyle("#000000");
									g2.strokeRect( -(5*strw)/8, -(5*strh)/8, (5*strw)/4, strh*1.2 );
								}
								g2.rotate( -a );
								g2.translate( -cx, -cy );
							} else g2.fillRect( nx-(5*strw)/8, y+ny-(5*strh)/8, (5*strw)/4, strh*1.2 );
						} else g2.fillRect( x+nx-(5*strw)/8, ny-strh/2.0, (5*strw)/4, strh*1.2 );
						//g2.fillRoundRect(startx, starty, width, height, arcWidth, arcHeight)
						//g2.fillOval( x+nx-k/2, ny-k/2, k, k );
						g2.setFillStyle( "#000000" );
					}
				}
				
				//int i = 0;
				if( vertical ) {
					if( showlinage ) {
						if( circular ) {
							if( use != null && use.length > 0 ) {
								drawMundi( g2, use, color, nstrh, frmh, frmo, y+realny, mleaves, (w-addon*2.0+5)*circularScale, false );
							}
							
							if( resnode.getMeta() != null && resnode.getMeta().length > 0 ) {
								List<String> metasplit = resnode.getMeta().split("_");
								
								int k = 0;
								for( String meta in metasplit ) {
									int mi = meta.indexOf( "[#" );
									if( mi == -1 ) mi = meta.length;
									int fi = meta.indexOf( "{" );
									if( fi == -1 ) fi = meta.length;
									String metadata = meta.substring(0,min(mi,fi));
									
									String metacolor = null;
									if( mi < meta.length ) {
										int me = meta.indexOf(']', mi+1 );
										metacolor = meta.substring(mi+1,me);
									}
									nstrh = strh;
									double mfrmh = strh;
									double metafontsize = 1.0;
									double metaframesize = 1.0;
									double metaframeoffset = -1.0;
									if( fi < meta.length ) {
										int fe = meta.indexOf('}', fi+1 );
										String metafontstr = meta.substring(fi+1,fe);
										List<String> mfsplit = metafontstr.split(" ");
										
										metafontsize = double.parse( mfsplit[0] );
										nstrh *= metafontsize;
										
										if( mfsplit.length > 1 ) {
											metaframesize = double.parse( mfsplit[1] );
											if( metaframesize != -1.0 ) mfrmh *= metaframesize;
										}
										if( mfsplit.length > 2 ) metaframeoffset = double.parse( mfsplit[2] );
									}
									
									k++;
									
									fontstr = (resnode.isSelected() ? "bold " : " ")+(int)nstrh+"px sans-serif";
									if( !fontstr.equals(g2.getFont()) ) g2.setFont( fontstr );
									drawMundi( g2, metadata, metacolor, nstrh, mfrmh, metaframeoffset, y+realny, mleaves, (w-addon*2.0+5)*circularScale/*+(k*metaframesize*4.0)*/, false );
								}
							}
						} else {
							g2.fillText(use, w-addon+10, y+realny+nstrh/2.3 );
							double hdiff = (dh*(mleaves-1)/2.0);
							g2.beginPath();
							g2.moveTo(w-addon+5, y+realny-hdiff);
							//g2.lineTo(w-addon, ny);
							g2.lineTo(w-addon+5, y+realny+hdiff);
							g2.stroke();
							g2.closePath();
						}
					} else {
						if( circular ) {
							double a = 2.0*pi*(y+ny)/h;
							double cx = (w+nx*circularScale*cos(a))/2.0;
							double cy = (w+nx*circularScale*sin(a))/2.0;
							
							g2.translate( cx, cy );
							if( internalrotate ) g2.rotate( a );
							g2.fillText(use, -strw/2.0, nstrh/2.3 );
							if( internalrotate ) g2.rotate( -a );
							g2.translate( -cx, -cy );
						} else {
							if( color != null && color.length > 0 ) { 
								g2.fillText(use, nx-strw/2.0, y+ny+nstrh/2.3 );
							} else {
								g2.fillText(use, nx-strw-2.0, y+ny-2.0 );
							}
							
							/*if( b ) {
								//for( String s : split ) {
									//g2.fillText(s, nx-strw/2.0, y+ny+strh/2-1-8*(split.length-1)+i*16 );
									//i++;
								//}
								g2.fillText(use, nx-strw/2.0, y+ny+nstrh/2.3 );
							} else {
								//for( String s : split ) {
									//g2.fillText(s, nx-strw/2.0, y+ny+strh/2-1-8*(split.length-1)+i*16 );
									//i++;
								//}
								g2.fillText(use, nx-strw/2.0, y+ny+nstrh/2.3 );
							}*/
						}
					}
				} else {
					if( color != null && color.length > 0 ) { 
						g2.fillText(use, x+nx-strw/2.0, ny+5 );
					} else {
						g2.fillText(use, x+nx-strw-2, ny-2 );
					}
					
					/*if( b ) {
						*for( String s : split ) {
							strw = g2.measureText( s ).getWidth();
							g2.fillText(s, x+nx-strw/2.0, ny+5-8*(split.length-1)+i*16 );
							i++;
						}*
						g2.fillText(use, x+nx-strw/2.0, ny+5 );
					} else {
						*for( String s : split ) {
							strw = g2.measureText(s).getWidth();
							g2.fillText(s, x+nx-strw/2.0, ny+6-8*(split.length)+i*16 );
							i++;
						}*
						g2.fillText(use, x+nx-strw/2.0, ny+6 );
					}*/
				}
			}
		}
	}

  double drawTreeRecursiveCenter( Canvas g2, Node node, double x, double y, double startx, double starty, int equalHeight, bool noAddHeight, bool vertical, double maxheight, double addon, String maxstr ) {
		Map<Node,double>	cmap = Map<Node,double>();
		int total = 0;
		double nyavg = 0.0;
		for( Node resnode in node.getNodes() ) {
			int nleaves = resnode.getLeavesCount();
			int nlevels = resnode.countMaxHeight();
			int plevels = resnode.countParentHeight();
			int mleaves = max(1, nleaves);
			
			double nx = 0;
			double ny = 0;
			
			if( vertical ) {
				ny = dh*total+(dh*mleaves)/2.0;
				if( equalHeight > 0 ) {
					//nx = w/25.0+dw*(w/dw-nlevels);
					
					if( equalHeight == 1 ) nx = 30.0+dw*(maxheight/dw-nlevels);
					else nx = 30.0+(dw*plevels);
				} else {
					nx = /*h/25+*/startx+(w*resnode.geth())/(maxheight*1.0);
				}

				if( nleaves == 0 ) {
					int v = (int)((nodearray.length*(y+ny))/canvas.getCoordinateSpaceHeight());
					if( v >= 0 && v < nodearray.length ) nodearray[v] = resnode;
				}
			} else {
				nx = dw*total+(dw*mleaves)/2.0;
				if( equalHeight > 0 ) {	
					ny = h/25.0+dh*(h/dh-nlevels);
				} else {
					ny = /*h/25+*/starty+(h*resnode.geth())/(maxheight*2.2);
				}
			}
			
			if( !resnode.isCollapsed() ) {
				if( vertical ) {
					double newy = dh*total + drawTreeRecursiveCenter( g2, resnode, x+w, y+dh*total, nx, (dh*mleaves)/2.0, equalHeight, noAddHeight, vertical, maxheight, addon, maxstr );
					cmap.put( resnode, newy );
					nyavg += newy;
				} else {
					drawTreeRecursiveCenter( g2, resnode, x+dw*total, y+h, (dw*mleaves)/2.0, /*noAddHeight?starty:*/ny, equalHeight, noAddHeight, vertical, maxheight, addon, maxstr );
				}
			} else {
				if( vertical ) resnode.setCanvasLoc( nx, y+dh*total+(dh*mleaves)/2.0 );
				else resnode.setCanvasLoc( x+dw*total+(dw*mleaves)/2.0, ny );
			}
			
			total += mleaves;
		}
		
		double ret = (node.getNodes() != null && node.getNodes().length > 0) ? nyavg/node.getNodes().length : dh/2.0;
		if( vertical ) {
			if( circular ) {
				double a = 2.0*pi*(y+ret)/h;
				node.setCanvasLoc( (w+startx*circularScale*cos(a))/2.0, (w+startx*circularScale*sin(a))/2.0 );
			} else node.setCanvasLoc( startx, y+ret );
			//node.setCanvasLoc( startx, y+ret );
		} else node.setCanvasLoc( x+ret, starty );
		total = 0;
		for( Node resnode in node.getNodes() ) {
			int nleaves = resnode.getLeavesCount();
			int nlevels = resnode.countMaxHeight();
			int plevels = resnode.countParentHeight();
			int mleaves = max(1, nleaves);
			
			double nx = 0;
			double ny = 0;
			
			if( vertical ) {
				ny = dh*total+(dh*mleaves)/2.0;
				if( equalHeight > 0 ) {
					if( equalHeight == 1 ) nx = 30.0+dw*(maxheight/dw-nlevels);
					else nx = 30.0+(dw*plevels);
				} else {
					nx = /*h/25+*/startx+(w*resnode.geth())/(maxheight*1.0);
				}

				if( nleaves == 0 ) {
					int v = (int)((nodearray.length*(y+ny))/canvas.getCoordinateSpaceHeight());
					if( v >= 0 && v < nodearray.length ) nodearray[v] = resnode;
				}
			} else {
				nx = dw*total+(dw*mleaves)/2.0;
				if( equalHeight > 0 ) {	
					ny = h/25.0+dh*(h/dh-nlevels);
				} else {
					ny = /*h/25+*/starty+(h*resnode.geth())/(maxheight*2.2);
				}
			}
			
			double newy = cmap.containsKey(resnode) ? cmap.get(resnode) : 0.0;
			if( resnode.isSelected() ) {
				g2.setStrokeStyle( "#000000" );
				g2.setLineWidth( 2.0 );
			} else {
				g2.setStrokeStyle( "#333333" );
				g2.setLineWidth( 1.0 );
			}
			g2.beginPath();
			if( vertical ) {
				double yfloor = y+newy; //Math.floor(y+newy);
				
				if( circular ) {
					double a1 = (2.0*pi*(y+ret))/h;
					double a2 = (2.0*pi*(yfloor))/h;
					
					g2.arc( w/2.0, w/2.0, startx*circularScale/2.0, a1, a2, a1 > a2 );
					/*if( a1 > a2 ) {
						g2.moveTo( (w+startx*circularScale*cos(a2))/2.0, (w+startx*circularScale*sin(a2))/2.0 );
						g2.arc( w/2.0, w/2.0, startx*circularScale/2.0, a2, a1 );
					} else {
						g2.moveTo( (w+startx*circularScale*cos(a1))/2.0, (w+startx*circularScale*sin(a1))/2.0 );
						g2.arc( w/2.0, w/2.0, startx*circularScale/2.0, a1, a2 );
					}*/
					g2.moveTo( (w+startx*circularScale*cos(a2))/2.0, (w+startx*circularScale*sin(a2))/2.0 );
					g2.lineTo( (w+nx*circularScale*cos(a2))/2.0, (w+nx*circularScale*sin(a2))/2.0 );
				} else {
					g2.moveTo( startx, y+ret );
					g2.lineTo( startx, yfloor );
					g2.moveTo( startx, yfloor );
					g2.lineTo( nx, yfloor );
				}
			} else {
				g2.moveTo( x+startx, starty );
				g2.lineTo( x+nx, starty );
				g2.lineTo( x+nx, ny );
			}
			g2.stroke();
			g2.closePath();
			
			if( showbubble ) {
				String ncolor = resnode.getColor();
				if( ncolor != null ) {
					g2.setFillStyle( ncolor );
				} else {
					g2.setFillStyle( "#000000" );
				}
				
				double mul = 1.0;
				if( resnode.getFrameSize() != -1 ) mul = resnode.getFrameSize();
				double radius = 1.5*mul;
				if( resnode.getNodes() == null || resnode.getNodes().length == 0 ) radius = 3.0*mul;
				g2.beginPath();
				if( vertical ) {
					double yfloor = y+newy; //Math.floor(y+newy);
					
					if( circular ) {
						double a = 2.0*pi*yfloor/h;
						g2.arc( (w+nx*circularScale*cos(a))/2.0, (w+nx*circularScale*sin(a))/2.0, radius, 0.0, 2*pi);
					} else {
						g2.arc(nx, yfloor, radius, 0.0, 2*pi);
					}
				} else {
					
				}
				g2.fill();
				g2.closePath();
			}
			//g2.setStroke( hStroke );
			//g2.setStroke( oldStroke );
			
			paintTree( g2, resnode, vertical, x, y, nx, newy /*Math.floor(newy)*/, addon, mleaves, ny, maxstr );
			total += mleaves;
		}
		
		return ret;
	}
	
	double drawTreeRecursive( Canvas g2, Node node, double x, double y, double startx, double starty, int equalHeight, bool noAddHeight, bool vertical, double maxheight, double addon, String maxstr ) {
		int total = 0;
		
		//double cirscl = 0.5;
		//double mdif = maxheight/w;
		//double cirmul = (cirscl-1.0)/mdif+1.0;
		double cx = startx*circularScale;
		if( vertical ) {
			if( circular ) {
				double a = 2.0*pi*(y+starty)/h;
				node.setCanvasLoc( (w+cx*cos(a))/2.0, (w+cx*sin(a))/2.0 );
			} else node.setCanvasLoc( startx, y+starty );
		} else node.setCanvasLoc( x+startx, starty );
		
		for( Node resnode in node.getNodes() ) {
			//String fontstr = (resnode.isSelected() ? "bold " : " ")+(int)(strh)+"px sans-serif";
			//if( !fontstr.equals(g2.getFont()) ) g2.setFont( fontstr );
			
			int nleaves = resnode.getLeavesCount();
			int nlevels = resnode.countMaxHeight();
			int plevels = resnode.countParentHeight();
			int mleaves = max(1, nleaves);
			
			double nx = 0;
			double ny = 0;
			
			if( vertical ) {
				//minh = 0.0;
				ny = dh*total+(dh*mleaves)/2.0;
				if( equalHeight > 0 ) {
					//w/25.0
					if( equalHeight == 1 ) nx = 30.0+dw*(maxheight/dw-nlevels);
					else nx = 30.0+(dw*plevels);
				} else {
					nx = /*h/25+*/startx+(w*resnode.geth())/(maxheight*1.0);
					//ny = 100+(int)(/*starty+*/(h*(node.h+resnode.h-minh))/((maxh-minh)*3.2));
				}

				if( nleaves == 0 ) {
					int v = (int)((nodearray.length*(y+ny))/canvas.getCoordinateSpaceHeight());
					//console( nodearray.length + "  " + canvas.getCoordinateSpaceHeight() + "  " + v );
					if( v >= 0 && v < nodearray.length ) nodearray[v] = resnode;
				}
			} else {
				//minh = 0.0;
				nx = dw*total+(dw*mleaves)/2.0;
				if( equalHeight > 0 ) {	
					ny = h/25.0+dh*(h/dh-nlevels);
				} else {
					ny = /*h/25+*/starty+(h*resnode.geth())/(maxheight*2.2);
					//ny = 100+(int)(/*starty+*/(h*(node.h+resnode.h-minh))/((maxh-minh)*3.2));
				}
			}
			double cnx = nx*circularScale;
			
			//int yoff = starty-k/2;
			/*System.err.println( resnode.meta );
			if( resnode.meta != null && resnode.meta.contains("Bulgaria") ) {
				System.err.println( resnode.nodes );
			}*/
			/*ci++;
			for( int i = colors.size(); i <= ci; i++ ) {
				colors.add( "rgb( "+(int)(rnd.nextFloat()*255)+", "+(int)(rnd.nextFloat()*255)+", "+(int)(rnd.nextFloat()*255)+" )" );
			}			
			String color = colors.get(ci);*/
			/*if( resnode.color != null ) {
				color = resnode.color;
			}*/
			
			if( !resnode.isCollapsed() ) {
				if( vertical ) {
					drawTreeRecursive( g2, resnode, x+w, y+dh*total, nx, (dh*mleaves)/2.0, equalHeight, noAddHeight, vertical, maxheight, addon, maxstr );
				} else {
					drawTreeRecursive( g2, resnode, x+dw*total, y+h, (dw*mleaves)/2.0, /*noAddHeight?starty:*/ny, equalHeight, noAddHeight, vertical, maxheight, addon, maxstr );
				}
			} else {
				if( vertical ) resnode.setCanvasLoc( nx, y+dh*total+(dh*mleaves)/2.0 );
				else resnode.setCanvasLoc( x+dw*total+(dw*mleaves)/2.0, ny );
			}
		
			//ny+=starty;
			//drawTreeRecursive( g2, resnode, w, h, dw, dh, x+dw*total, y+h, (dw*nleaves)/2, ny, paint ? shadeColor : null );
			
			if( resnode.isSelected() ) {
				g2.setStrokeStyle( "#000000" );
				g2.setLineWidth( 2.0 );
			}
			else {
				g2.setStrokeStyle( "#333333" );
				g2.setLineWidth( 1.0 );
			}
			//g2.setStroke( vStroke );
			g2.beginPath();
			if( vertical ) {
				double yfloor = y+ny; //Math.floor(y+ny);
				if( circular ) {
					double a1 = (2.0*pi*(y+starty))/h;
					double a2 = (2.0*pi*(yfloor))/h;
					
					g2.arc( w/2.0, w/2.0, cx/2.0, a1, a2, a1 > a2 );
					/*if( a1 > a2 ) {
						g2.moveTo( (w+startx*circularScale*cos(a2))/2.0, (w+startx*circularScale*sin(a2))/2.0 );
						//g2.moveTo( (w+startx*cos(y+starty))/2.0, (w+startx*sin(y+starty))/2.0 );
						g2.arc( w/2.0, w/2.0, startx*circularScale/2.0, a2, a1 );
					} else {
						g2.moveTo( (w+startx*circularScale*cos(a1))/2.0, (w+startx*circularScale*sin(a1))/2.0 );
						//g2.moveTo( (w+startx*cos(y+starty))/2.0, (w+startx*sin(y+starty))/2.0 );
						g2.arc( w/2.0, w/2.0, startx*circularScale/2.0, a1, a2 );
					}*/
					//g2.closePath();
					//g2.stroke();
					//g2.beginPath();
					g2.moveTo( (w+cx*cos( a2 ))/2.0, (w+cx*sin( a2 ))/2.0 );
					g2.lineTo( (w+cnx*cos( a2 ))/2.0, (w+cnx*sin( a2 ))/2.0 );
					//g2.closePath();
				} else {
					g2.moveTo( startx, y+starty );
					g2.lineTo( startx, yfloor );
					//g2.moveTo( startx, yfloor );
					g2.lineTo( nx, yfloor );
				}
			} else {
				g2.moveTo( x+startx, starty );
				g2.lineTo( x+nx, starty );
				g2.lineTo( x+nx, ny );
			}
			g2.stroke();
			g2.closePath();
			
			if( showbubble ) {
				String ncolor = resnode.getColor();
				if( ncolor != null ) {
					g2.setFillStyle( ncolor );
				} else {
					g2.setFillStyle( "#000000" );
				}
				
				g2.beginPath();
				double mul = 1.0;
				if( resnode.getFrameSize() != -1 ) mul = resnode.getFrameSize();
				double radius = 1.5*mul;
				if( resnode.getNodes() == null || resnode.getNodes().size() == 0 ) radius = 3.0*mul;
				if( vertical ) {
					double yfloor = y+ny; //Math.floor(y+ny);
					if( circular ) {
						double a = 2.0*pi*yfloor/h;
						g2.arc( (w+nx*circularScale*cos(a))/2.0, (w+nx*circularScale*sin(a))/2.0, radius, 0.0, 2*pi);
					} else {
						g2.arc(nx, yfloor, radius, 0.0, 2*pi);
					}
				} else {
					
				}
				g2.fill();
				g2.closePath();
			}
			//g2.setStroke( hStroke );
			//g2.setStroke( oldStroke );
			
			paintTree( g2, resnode, vertical, x, y, nx, ny, addon, mleaves, ny, maxstr );
			total += mleaves;
		}
		
		return /*(node.getNodes() != null && node.getNodes().size() > 0) ? nyavg/node.getNodes().size() : */0.0;
	}

  double getMaxInternalNameLength( Node n, Canvas ctx ) {
		double ret = 0.0;
		String name = n.getName();
		List<Node> nl = n.getNodes();
		if( nl != null ) {
			if( name != null && nl.length > 0 ) ret = ctx.measureText( name ).getWidth();
		
			for( Node nn in n.getNodes() ) {
				double val = getMaxInternalNameLength( nn, ctx );
				if( val > ret ) ret = val;
			}
		}
		return ret;
	}

  double getHeight( Node n ) {
		double h = n.geth();
		double d = h + ((n.getParent() != null) ? getHeight( n.getParent() ) : 0.0);
		return d;
	}
	
	void recursiveLeavesGet( Node root, List<Node> leaves ) {
		List<Node> nodes = root.getNodes();
		if( nodes == null || nodes.length == 0 ) {
			leaves.add( root );
		} else {
			for( Node n in nodes ) {
				recursiveLeavesGet( n, leaves );
			}
		}
	}
	
	Node getMaxNameLength( Node root, Canvas ctx ) {
		List<Node>	leaves = [];
		recursiveLeavesGet( root, leaves );
		
		Node sel = null;
		double max = 0.0;
		//console( ""+leaves.length);
		for( Node node : leaves ) {
			String name = node.getName();
			//if( node.getMeta() != null ) name += " ("+node.getMeta()+")";
			TextMetrics tm = ctx.measureText( name );
			double tw = tm.getWidth();
			//double h = node.getHeight();
			//double val = h/(ww-tw);
			if( tw > max ) {
				max = tw;
				sel = node;
			}
		}
		
		return sel;
	}

  Node getMaxHeight( Node root, Canvas ctx, int ww, bool includetext ) {
		List<Node>	leaves = [];
		recursiveLeavesGet( root, leaves );
		
		Node sel = null;
		double max = 0.0;
		
		if( includetext ) {
			for( Node node in leaves ) {
				String name = node.getName();
				//if( node.getMeta() != null ) name += " ("+node.getMeta()+")";
				TextMetrics tm = ctx.measureText( name );
				double tw = tm.getWidth();
				double h = node.getHeight();
				
				double val = h/(ww-tw);
				if( val > max ) {
					max = val;
					sel = node;
				}
			}
		} else {
			for( Node node in leaves ) {
				double h = node.getHeight();
				if( h > max ) {
					max = h;
					sel = node;
				}
			}
		}
		
		/*if( sel != null ) {
			String name = sel.getName();
			if( sel.getMeta() != null ) name += " ("+sel.getMeta()+")";
			console( name );
		}*/
		
		return sel;
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

  List<double> parseDistance( int len, List<String> lines, List<String> names ) {
		List<double> dvals = List.filled(len*len,0.0);
		int m = 0;
		int u = 0;
		for( int i = 1; i < lines.length; i++ ) {
			String line = lines[i];
			List<String> ddstrs = line.split("[ \t]+");
			if( !line.startsWith(" ") ) {
				m++;
				u = 0;
				
				//int si = ddstrs[0].indexOf('_');
				//String name = si == -1 ? ddstrs[0] : ddstrs[0].substring( 0, si );
				//console( "name: " + name );
				
				String name = ddstrs[0];
				names.add( name );
			}
			if( ddstrs.length > 2 ) {
				for( int k = 1; k < ddstrs.length; k++ ) {
					int idx = (m-1)*len+(u++);
					if( idx < dvals.length ) dvals[idx] = double.parse(ddstrs[k]);
					//else console( m + " more " + u );
				}
			}
		}
		
		return dvals;
	}

  List<Sequence> importReader( String str ) {
		List<Sequence> lseq = [];
		int i = str.indexOf('>');
		int e = 0;
		String name = null;
		while( i != -1 ) {
			if( name != null ) {
				Sequence s = new Sequence.nameBuffer( name, str.substring(e+1, i-1), null );
				s.checkLengths();
				lseq.add( s );
			}
			e = str.indexOf('\n',i);
			name = str.substring(i+1, e);
			i = str.indexOf('>', e);
		}
		if( name != null ) {
			Sequence s = new Sequence.nameBuffer( name, str.substring(e+1, str.length), null );
			s.checkLengths();
			lseq.add( s );
		}
		return lseq;
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
					
					Map<String,String> namemap = new Map<String,String>();
					int t = str.indexOf("translate");
					int n = str.indexOf("\n", t);
					int c = str.indexOf(";", n);
					
					String treelist = str.substring(n+1, c);
					List<String> split = treelist.split(",");
					for( String name in split ) {
						String trim = name.trim();
						int v = trim.indexOf(' ');
						namemap[trim.substring(0, v)] = trim.substring(v+1);
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
					
					/* mumu
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
					});*/
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
						
						/* mumu
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
            */
					}
				} else {
					List<String> lines = str.split("\n");
					names = lines[0].split("\t");
					len = names.length;
					dvals = List.filled(len*len,0.0);
					for( int i = 1; i < lines.length; i++ ) {
						List<String> ddstrs = lines[i].split("\t");
						if( ddstrs.length > 1 ) {
							int k = 0;
							for( String ddstr in ddstrs ) {
								dvals[(i-1)*len+(k++)] = double.parse(ddstr);
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