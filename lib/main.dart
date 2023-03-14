import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'LoadMoreSliver.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<int> _demoList() {
    var list = <int>[];
    for (int i = 0; i < 20; i++) {
      list.add(random.nextInt(255));
    }
    return list;
  }

  var ll = <int>[];

  @override
  void initState() {
    super.initState();
    ll.addAll(_demoList());
  }

  var random = Random();

  var index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title} ${ll.length}"),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: () {
              return Future.delayed(const Duration(seconds: 2)).then((value) {
                setState(() {
                  ll = _demoList();
                });
              });
            },
          ),
          SliverList(
              delegate: SliverChildListDelegate.fixed(ll
                  .map((e) => Container(
                        color: Color.fromARGB(255, e, e, e),
                        height: 100,
                      ))
                  .toList())),
          LoadMoreSliver(
            onLoad: () {
              var type = [LoadMoreSliverType.ERROR, LoadMoreSliverType.NORMAL, LoadMoreSliverType.NONE][index++ % 3];
              return Future.delayed(const Duration(seconds: 2)).then((value) {
                if (type == LoadMoreSliverType.NORMAL) {
                  setState(() {
                    ll.addAll(_demoList());
                  });
                }
              }).then((value) => type);
            },
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
