import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:cache_image/cache_image.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
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
        primaryColor: Colors.white,
      ),
      home: MyHomePage(title: 'Flutter Cache Image'),
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

  void _refresh() {
    getTemporaryDirectory().then((dir){
      dir.delete(recursive: true);
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
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
        backgroundColor: CupertinoColors.white,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title, style: TextStyle(color: CupertinoColors.black),),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: FadeInImage(
                    fit: BoxFit.cover,
                    placeholder: AssetImage('assets/placeholder.png'),
                    image: CacheImage('gs://testing-9ea12.appspot.com/bake-1706051_1920.jpg')
                  ),
                ),
                Positioned(
                    top:  0,
                    right: 0,
                    child: Container(
                      margin: EdgeInsets.all(16.0),
                      padding: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 16.0, left: 16.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.black54,
                              blurRadius: 10.0,
                              spreadRadius: 1.0,
                              offset: new Offset(2.0, 1.0),
                            )
                          ],
                          borderRadius: BorderRadius.circular(16.0)
                      ),
                      child: Text("Firebase Storage"),
                    )
                ),
              ],
            ),
          ),
          Container(height: 4.0),
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: FadeInImage(
                    fit: BoxFit.cover,
                    placeholder: AssetImage('assets/placeholder.png'),
                    image: CacheImage('https://hd.tudocdn.net/874944?w=646&h=284', duration: Duration(seconds: 2), durationExpiration: Duration(seconds: 10))
                  ),
                ),
                Positioned(
                  top:  0,
                  right: 0,
                  child: Container(
                    margin: EdgeInsets.all(16.0),
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 16.0, left: 16.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          new BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10.0,
                            spreadRadius: 1.0,
                            offset: new Offset(2.0, 1.0),
                          )
                        ],
                        borderRadius: BorderRadius.circular(16.0)
                    ),
                    child: Text("Network"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.refresh, color: CupertinoColors.black),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
