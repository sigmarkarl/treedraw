import 'package:flutter/material.dart';
import 'package:treedraw/treeutil.dart';
import 'treepainter.dart';
import 'treedraw.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  TreeDraw treeDraw = TreeDraw();
  String tree =
      "(MT.ruberDSM1279:0.14903,MT.silvanusDSM9946:0.15015,(T.filiformis:0.10766,(T.oshimai:0.08602,(((T.brockianus:0.03466,<i>T.eggertsoni</i>:0.0333):0.04428,(((((((T.scotoductus1572:0.0113,T.scotoductus2101:0.01043):0.00037,T.scotoductus2127:0.01287):0.00086,(T.scotoductusSA01:-0.00001,T.scotoductus4063:0.00001):0.01315):0.00346,T.scotoductus346:0.01502):0.00363,T.scotoductus252:0.02305):0.00366,T.antranikiani:0.02794):0.06363,T.kawarayensis:0.06805):0.00298):0.00453,((T.thermophilusHB27:0.00411,T.thermophilusHB8:0.00409):0.07548,((T.aquaticus:0.07363,T.islandicus:0.07487):0.00245,(T.igniterrae:0.03362):0.03362):0.00354):0.00325):0.00605):0.02099):0.08672)";
  //TreeDraw treeDraw = TreeDraw();

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      treeDraw.hchunk *= 1.25;
    });
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
      body: CustomPaint(
        painter: TreePainter(treeDraw, tree),
        size: Size(1024, 1024),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            ListTile(
              title: const Text('Default'),
              leading: Radio(
                value: "Default",
                groupValue: "TreeType",
                onChanged: (String value) {
                  setState(() {
                    treeDraw.radial = false;
                    treeDraw.circular = false;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Circular'),
              leading: Radio(
                value: "Circular",
                groupValue: "TreeType",
                onChanged: (String value) {
                  setState(() {
                    treeDraw.radial = false;
                    treeDraw.circular = true;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Radial'),
              leading: Radio(
                value: "Radial",
                groupValue: "TreeType",
                onChanged: (String value) {
                  setState(() {
                    treeDraw.radial = true;
                    treeDraw.circular = false;
                  });
                },
              ),
            ),
            FlatButton(
              child: Text("Circular"),
              color: Colors.blue,
              splashColor: Colors.blueAccent,
              onPressed: () {
                setState(() {
                  treeDraw.circular = !treeDraw.circular;
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
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _decrementCounter,
        tooltip: 'Decrement',
        child: Icon(Icons.remove),
      ), // This trailing comma makes auto-formatting nicer for build methods.*/
    );
  }
}
