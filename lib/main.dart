import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:treedraw/treeutil.dart';
import 'treepainter.dart';
import 'treedraw.dart';
import 'node.dart';
import 'mobileappdrop.dart' if (dart.library.js) 'webappdrop.dart';

import 'dart:ui';
import 'dart:async';
//import 'dart:html';
//import 'dart:js' as js;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

TreeUtil treeutil = TreeUtil.fromTree(
    //"(MT.ruberDSM1279:0.14903,MT.silvanusDSM9946:0.15015,(T.filiformis:0.10766,(T.oshimai:0.08602,(((T.brockianus:0.03466,<i>T.eggertsoni</i>:0.0333):0.04428,(((((((T.scotoductus1572:0.0113,T.scotoductus2101:0.01043):0.00037,T.scotoductus2127:0.01287):0.00086,(T.scotoductusSA01:-0.00001,T.scotoductus4063:0.00001):0.01315):0.00346,T.scotoductus346:0.01502):0.00363,T.scotoductus252:0.02305):0.00366,T.antranikiani:0.02794):0.06363,T.kawarayensis:0.06805):0.00298):0.00453,((T.thermophilusHB27:0.00411,T.thermophilusHB8:0.00409):0.07548,((T.aquaticus:0.07363,T.islandicus:0.07487):0.00245,(T.igniterrae:0.03362):0.03362):0.00354):0.00325):0.00605):0.02099):0.08672)"
    "(T.scotoductus_17:0.00055,T.scotoductus_27:0.00066,((T.scotoductus_34:0.0,T.scotoductus_38:0.0):0.00055,(T.scotoductus_1:0.00132,((T.scotoductus_24:0.00055,T.scotoductus_28:0.00055)0.906:0.00055,((T.scotoductus_10:0.00055,T.scotoductus_18:0.00132)0.906:0.00055,(((T.scotoductus_12:0.0,T.scotoductus_19:0.0,T.scotoductus_2:0.0,T.scotoductus_21:0.0,T.scotoductus_23:0.0,T.scotoductus_31:0.0,T.scotoductus_6:0.0,T.scotoductus_7:0.0):0.00055,((T.scotoductus_26:0.0,T.scotoductus_4:0.0):0.00055,(T.scotoductus_3:0.00055,(((T.scotoductus_15:0.0,T.scotoductus_29:0.0,T.scotoductus_37:0.0,T.scotoductus_8:0.0,T.scotoductus_9:0.0):0.00055,(T.scotoductus_16:0.00066,T.scotoductus_32:0.00055)0.444:0.00055)0.859:0.00051,((T.scotoductus_KI2_1:0.00095,(T.scotoductus_KI2:0.00159,(((T.tenuipuniceus_YIM:0.02071,((T.tengchongensis_YIM_1:0.00055,(T.tengchongensis_15Y:0.00131,T.tengchongensis_YIM:0.00052)0.928:0.00055)1.000:0.01719,((T.caldilimi_YIM:0.00176,T.caldilimi_YIM_1:0.00422)0.984:0.00885,((T.caliditerrae_YIM:0.0,T.caliditerrae_YIM_1:0.0):0.01201,(T.thermamylovorans_CFH:0.01602,(((T.igniterrae_RF-4:0.0,T.igniterrae_RF-4_1:0.0):0.00369,((((T.aquaticus_Y51MC23:0.00054,(T.aquaticus_YT-1:0.00055,T.aquaticus_YT-1_1:0.00055)0.933:0.00197)0.999:0.01307,(((T.filiformis_ATCC_43280:0.00055,T.filiformis_ATCC_43280_1:0.00065)1.000:0.04060,(T.sp._JCM:0.00919,((T.oshimai_SPS-17:0.00103,(T.oshimai_JL-2:0.00055,T.oshimai_JL-2_1:0.00055)0.844:0.00098)1.000:0.06351,(((T.thermophilus_HB27c:0.0,T.thermophilus_HB27c_1:0.0):0.00055,(T.thermophilus_ATCC_33923:0.00055,(T.thermophilus_HB27:0.0,T.thermophilus_HB27_1:0.0,T.thermophilus_HB5002:0.0,T.thermophilus_HB5002_1:0.0,T.thermophilus_HB5008:0.0,T.thermophilus_HB5008_1:0.0):0.00055)0.843:0.00055)0.930:0.00053,(((T.thermophilus_HB5018:0.0,T.thermophilus_HB5018_1:0.0,T.thermophilus_HB8:0.0,T.thermophilus_HC11:0.0):0.00055,T.thermophilus_HB8_1:0.00055)0.940:0.00055,((((T.parvatiensis_RL:0.0,T.thermophilus_SG0.5JP17-16_1:0.0):0.00055,T.thermophilus_IB-21:0.00066)0.917:0.00055,((T.thermophilus_JL-18:0.0,T.thermophilus_JL-18_1:0.0):0.00055,((T.thermophilus_AA2-20:0.0,T.thermophilus_AA2-20_1:0.0,T.thermophilus_AA2-29:0.0,T.thermophilus_AA2-29_1:0.0):0.00055,((T.parvatiensis_RL_1:0.00055,T.thermophilus_SG0.5JP17-16:0.00055)0.856:0.00110,T.thermophilus_HC11_1:0.00066)1.000:0.00055)0.941:0.00055)0.917:0.00055)0.781:0.00132,(T.thermophilus_unknown:0.00055,T.thermophilus_unknown_1:0.00055)0.917:0.00055)0.917:0.00055)0.930:0.00055)0.914:0.00688)0.997:0.01375)0.843:0.00490)0.959:0.00674,(T.kawarayensis_JCM:0.01080,((T.arciformis_CGMCC:0.0,T.arciformis_CGMCC_1:0.0):0.00055,T.arciformis_CGMCC_2:0.00055)0.950:0.00536)0.884:0.00549)0.892:0.00442)0.901:0.00581,((T.sediminis_L198:0.0,T.sediminis_L198_1:0.0):0.01707,(T.islandicus_DSM_21543:0.0,T.islandicus_DSM_21543_1:0.0):0.01406)0.796:0.00520)0.997:0.01341,(T.sp._2.9:0.00770,(T.brockianus_GE-1:0.00055,T.brockianus_GE-1_1:0.00055)0.962:0.00504)0.997:0.01199)0.818:0.00429)0.395:0.00874,(T.sp._CCB:0.00065,T.sp._CCB_1:0.00055)0.999:0.01596)0.983:0.01162)0.976:0.00930)0.939:0.00753)0.948:0.00504)0.929:0.00638)0.440:0.00524,(T.caldifontis_YIM:0.01238,(T.amyloliquefaciens_YIM:0.00266,T.amyloliquefaciens_YIM_1:0.00067)1.000:0.01450)0.432:0.00249)0.934:0.00644,((T.scotoductus_13:0.0,T.scotoductus_30:0.0,T.scotoductus_33:0.0):0.00148,T.scotoductus_SA-01:0.00187)0.094:0.00175)0.407:0.00157)0.474:0.00179)0.951:0.00282,((T.scotoductus_11:0.0,T.scotoductus_22:0.0):0.00055,(T.scotoductus_14:0.00066,T.scotoductus_5:0.00055)0.992:0.00055)0.984:0.00054)0.364:0.00066)0.787:0.00088)0.997:0.00134)0.501:0.00056)1.000:0.00077,(T.scotoductus_25:0.00055,T.scotoductus_39:0.00055)0.885:0.00066)0.906:0.00055)0.099:0.00066)0.906:0.00055)0.273:0.00055)0.735:0.00055)");

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

_launchURLSimple(String url) async {
  await launch(url);
}

enum LongPressBehaviour { root, reroot }
enum TreeDrawStyle { center, branch }
enum TreeType { vertical, circular, radial }

class _MyHomePageState extends State<MyHomePage> {
  //String tree =
  //    "(MT.ruberDSM1279:0.14903,MT.silvanusDSM9946:0.15015,(T.filiformis:0.10766,(T.oshimai:0.08602,(((T.brockianus:0.03466,<i>T.eggertsoni</i>:0.0333):0.04428,(((((((T.scotoductus1572:0.0113,T.scotoductus2101:0.01043):0.00037,T.scotoductus2127:0.01287):0.00086,(T.scotoductusSA01:-0.00001,T.scotoductus4063:0.00001):0.01315):0.00346,T.scotoductus346:0.01502):0.00363,T.scotoductus252:0.02305):0.00366,T.antranikiani:0.02794):0.06363,T.kawarayensis:0.06805):0.00298):0.00453,((T.thermophilusHB27:0.00411,T.thermophilusHB8:0.00409):0.07548,((T.aquaticus:0.07363,T.islandicus:0.07487):0.00245,(T.igniterrae:0.03362):0.03362):0.00354):0.00325):0.00605):0.02099):0.08672)";
  TreeDraw treeDraw = TreeDraw.withTreeUtil(treeutil);
  double canvasWidth = 4096;
  double canvasHeight = 4096;
  //treeDraw.setTreeUtil(treeutil, str);

  Node selectedNode;
  TreeDrawStyle treeDrawStyle = TreeDrawStyle.branch;
  TreeType treeType = TreeType.vertical;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      treeDraw.hchunk *= 1.25;

      int leaves = treeDraw.root.getLeavesCount();
      var hsize = (treeDraw.hchunk * leaves);
      canvasHeight = hsize;
      canvasWidth = 4096;
      //var h = treeDraw.getHeight(treeDraw.root);
      //debugPrint("hh " + h.toString());
    });
  }

  void _decrementCounter() {
    setState(() {
      treeDraw.hchunk *= 0.8;

      int leaves = treeDraw.root.getLeavesCount();
      var hsize = (treeDraw.hchunk * leaves);
      canvasHeight = hsize;
      canvasWidth = 4096;
    });
  }

  AppDrop appDrop = getAppDrop(treeutil);

  @override
  void initState() {
    super.initState();
    appDrop.init(this);
  }

  @override
  void dispose() {
    appDrop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          /*onHorizontalDragStart: (detail) {
            _x = detail.globalPosition.dx;
          },
          onVerticalDragStart: (detail) {
            _y = detail.globalPosition.dy;
          },
          onHorizontalDragUpdate: (detail) {
            setState(() {
              _len -= detail.globalPosition.dx - _x;
              _x = detail.globalPosition.dx;
            });
          },
          onVerticalDragUpdate: (detail) {
            setState(() {
              _len += detail.globalPosition.dy - _y;
              _y = detail.globalPosition.dy;
            });
          },*/
          onLongPressStart: (details) {
            setState(() {
              var x = details.localPosition.dx;
              var y = details.localPosition.dy;
              var selectedNode = treeDraw.findSelectedNode(treeDraw.root, x, y);
              if (selectedNode != null) {
                treeDraw.pressroot == LongPressBehaviour.root
                    ? treeDraw.setNode(selectedNode)
                    : treeDraw.reroot(selectedNode);
              }
            });
          },
          onTapDown: (details) {
            setState(() {
              var x = details.localPosition.dx;
              var y = details.localPosition.dy;
              var selectedNode = treeDraw.findSelectedNode(treeDraw.root, x, y);
              if (selectedNode != null) {
                this.selectedNode = selectedNode;
                treeDraw.selectRecursive(
                    selectedNode, !selectedNode.isSelected());
              }
            });
          },
          /*onTap: () {
            setState(() {
              //var x = detail.globalPosition.x;
              //var selectedNode = findSelectedNode(root, x, y);
              //if (selectedNode != null) {
              //  selectRecursive(selectedNode, !selectedNode.isSelected());
              //}
            });
          },
          child: DragTarget(
            builder: (context, List<String> candidateData, rejectedData) {
              return CustomPaint(
                painter: TreePainter(treeDraw),
                size: Size(1024, 1024),
              );
            },
            onWillAccept: (data) {
              return true;
            },
            onAccept: (data) {
              var k = 0;
            },
          ),*/
          child: CustomPaint(
            painter: TreePainter(treeDraw),
            size: Size(canvasWidth, canvasHeight),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Text("Tree type"),
            ListTile(
              title: const Text('Default'),
              leading: Radio(
                value: TreeType.vertical,
                groupValue: treeType,
                onChanged: (TreeType value) {
                  setState(() {
                    treeType = value;
                    treeDraw.radial = false;
                    treeDraw.circular = false;
                    Navigator.pop(context);
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Circular'),
              leading: Radio(
                value: TreeType.circular,
                groupValue: treeType,
                onChanged: (TreeType value) {
                  setState(() {
                    treeType = value;
                    treeDraw.radial = false;
                    treeDraw.circular = true;
                    Navigator.pop(context);
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Radial'),
              leading: Radio(
                value: TreeType.radial,
                groupValue: treeType,
                onChanged: (TreeType value) {
                  setState(() {
                    treeType = value;
                    treeDraw.radial = true;
                    treeDraw.circular = false;
                    Navigator.pop(context);
                  });
                },
              ),
            ),
            Divider(),
            Text("Tree draw style"),
            ListTile(
              title: const Text('Center'),
              leading: Radio(
                value: TreeDrawStyle.center,
                groupValue: treeDrawStyle,
                onChanged: (TreeDrawStyle value) {
                  setState(() {
                    treeDrawStyle = value;
                    treeDraw.center = true;
                    Navigator.pop(context);
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Branch'),
              leading: Radio(
                value: TreeDrawStyle.branch,
                groupValue: treeDrawStyle,
                onChanged: (TreeDrawStyle value) {
                  setState(() {
                    treeDrawStyle = value;
                    treeDraw.center = false;
                    Navigator.pop(context);
                  });
                },
              ),
            ),
            Divider(),
            Text("Long press"),
            ListTile(
              title: const Text('Reroot'),
              leading: Radio(
                value: LongPressBehaviour.reroot,
                groupValue: treeDraw.pressroot,
                onChanged: (LongPressBehaviour value) {
                  setState(() {
                    treeDraw.pressroot = value;
                    Navigator.pop(context);
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Root'),
              leading: Radio(
                value: LongPressBehaviour.root,
                groupValue: treeDraw.pressroot,
                onChanged: (LongPressBehaviour value) {
                  setState(() {
                    treeDraw.pressroot = value;
                    Navigator.pop(context);
                  });
                },
              ),
            ),
            Divider(),
            TextButton(
              child: Text("Delete selection"),
              //color: Colors.blue,
              //splashColor: Colors.blueAccent,
              onPressed: () {
                setState(() {
                  var parent = selectedNode.getParent();
                  if (parent != null) parent.removeNode(selectedNode);
                  selectedNode = null;
                  treeDraw.root.countLeaves();
                  Navigator.pop(context);
                });
              },
            ),
            TextButton(
              child: Text("Keep selection"),
              //color: Colors.blue,
              //splashColor: Colors.blueAccent,
              onPressed: () {
                setState(() {
                  //treeDraw.delete()
                  Navigator.pop(context);
                });
              },
            ),
            Divider(),
            TextButton(
              child: Text("Save"),
              //color: Colors.blue,
              //splashColor: Colors.blueAccent,
              onPressed: () {
                setState(() {
                  final recorder = PictureRecorder();
                  final size = Size(1024.0, 1024.0);
                  final canvas = new Canvas(
                      recorder,
                      new Rect.fromPoints(
                          new Offset(0.0, 0.0), new Offset(1024.0, 1024.0)));

                  treeDraw.handleTree(canvas, size);
                  final picture = recorder.endRecording();
                  final img = picture.toImage(1024, 1024);
                  img.then((value) {
                    value
                        .toByteData(format: ImageByteFormat.png)
                        .then((pngBytes) {
                      var imgurl = Uri.dataFromBytes(
                          pngBytes.buffer.asUint8List(),
                          mimeType: "image/png");
                      var imgurlstr = imgurl.toString();
                      //_launchURLSimple(imgurl.toString());
                      var b = Base64Encoder();
                      String erm = b.convert(pngBytes.buffer.asUint8List());
                      var imgurlstr2 = "data:image/png;base64," + erm;
                      var encoded = Uri.encodeFull(imgurlstr2);

                      debugPrint(encoded.compareTo(imgurlstr).toString() +
                          " " +
                          (encoded.length - imgurlstr.length).toString());

                      _launchURLSimple(
                          "data:text/plain;base64,SGVsbG8sIFdvcmxkIQ==");
                    });
                  });
                  //js.context.callMethod('open', ['']);
                  //treeDraw.circular = !treeDraw.circular;
                });
              },
            ),
            /*Expanded(
              child: ListView.builder(
                controller: _trackingScrollController,
                // Let the ListView know how many items it needs to build.
                itemCount: listi.length, //items.length,
                // Provide a builder function. This is where the magic happens.
                // Convert each item into a widget based on the type of item it is.
                itemBuilder: (context, index) {
                  //final item = items[index];

                  return ListTile(
                    onTap: () {
                      setState(() {
                        listi[index].selected = !listi[index].selected;
                        updateVisibility();
                        //log( paints[index].selected.toString());
                      });
                    },
                    title:
                        Text(listi[index].country), //item.buildTitle(context),
                    subtitle:
                        Text(listi[index].id), //item.buildSubtitle(context),
                    selected: listi[index].selected,
                    trailing: listi[index].selected
                        ? Icon(Icons.check_box)
                        : Icon(Icons.check_box_outline_blank),
                  );
                },
              ),
            ),*/
            TextField(
              onChanged: (val) {
                setState(() {
                  //listi = viewlist.where((element) => element.country.contains(val)).toList();
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Filter',
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: _decrementCounter,
              tooltip: 'Decrement',
              child: Icon(Icons.remove),
            ),
          ],
        ),
      ),
      /*FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),*/
      /*floatingActionButton: FloatingActionButton(
        onPressed: _decrementCounter,
        tooltip: 'Decrement',
        child: Icon(Icons.remove),
      ), // This trailing comma makes auto-formatting nicer for build methods.*/
    );
  }
}
