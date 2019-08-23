import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;


Future<Postlist> fetchPost() async {
  final response =
//  await http.get('https://jsonplaceholder.typicode.com/posts/1');
  await http.get('http://10.0.2.2:8000/API/articles/?format=json');
  var completer = new Completer();

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
//    print(json.decode(response.body));
//    print(json.decode(response.body).length);
//    for (var test in json.decode(response.body)) {
//      print(test['title']);
//    }

    print(response.body);

    return Postlist.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class Postlist {
  final List<Post> list;

  Postlist({this.list});

  factory Postlist.fromJson(json) {

    List<Post> Posts = new List<Post>(json.length);

    int counter = 0;
    for (var index in json) {
      Posts[counter] = Post(
          upvote : index['upvote'],
          title : index['title'],
          image : index['image']
      );
      counter++;
    }
    return Postlist(
        list: Posts
    );
  }
}

class Post {
  final int upvote;
  final String title;
  final String image;

  Post({this.upvote, this.title, this.image});

  factory Post.fromJson(json) {
    return Post(
      upvote: json['upvote'],
      title: json['title'],
      image: json['image'],
    );
  }
}


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}


final Uint8List kTransparentImage = new Uint8List.fromList(<int>[
  0x89,  0x50,  0x4E,  0x47,  0x0D,  0x0A,  0x1A,  0x0A,  0x00,  0x00,  0x00,  0x0D,
  0x49,  0x48,  0x44,  0x52,  0x00,  0x00,  0x00,  0x01,  0x00,  0x00,  0x00,  0x01,
  0x08,  0x06,  0x00,  0x00,  0x00,  0x1F,  0x15,  0xC4,  0x89,  0x00,  0x00,  0x00,
  0x0A,  0x49,  0x44,  0x41,  0x54,  0x78,  0x9C,  0x63,  0x00,  0x01,  0x00,  0x00,
  0x05,  0x00,  0x01,  0x0D,  0x0A,  0x2D,  0xB4,  0x00,  0x00,  0x00,  0x00,  0x49,
  0x45,  0x4E,  0x44,  0xAE,
]);

List<IntSize> _createSizes(int count) {
  Random rnd = new Random();
  return new List.generate(count,
          (i) => new IntSize((rnd.nextInt(500) + 200), rnd.nextInt(800) + 200));
}

class SayProject extends StatefulWidget {
  @override
  _SayProjectState createState() => _SayProjectState();
}

class _SayProjectState extends State<SayProject> {
  Postlist postList;

  _SayProjectState() {
    fetchPost().then((value) => setState(() {
      postList = value;
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text("Say::Project"),
            floating: true,
            snap: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12.0),
            sliver: SliverStaggeredGrid(
              delegate: SliverChildBuilderDelegate(
                      (context, index) => _Tile(index, postList.list[index])
              ),
              gridDelegate: SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 100.0,
                  mainAxisSpacing: 0.0,
                  crossAxisSpacing: 8.0,
                  staggeredTileBuilder: (index) => new StaggeredTile.fit(2)
              ),
            ),
          )
        ],
      ),
    );
  }
}


class MyHomePage extends StatelessWidget {
  MyHomePage() : _sizes = _createSizes(_kItemCount).toList();

  static const int _kItemCount = 1000;
  final List<IntSize> _sizes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Center(child: Text("Say::Project", style: TextStyle(color: Colors.black),)),
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          FutureBuilder(
              future: fetchPost(),
              builder: (context, snapshot) {
                if (snapshot.hasData) return SliverPadding(
                  padding: const EdgeInsets.all(12.0),
                  sliver: SliverStaggeredGrid(
                    delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                        new _Tile(index, snapshot.data.list[index])
//                        (context, index) => FutureBuilder(
//                            future: fetchPost(),
//                            builder: (context, snapshot) {
//                              if (snapshot.hasData) {
//                                return new _Tile(index, snapshot.data.list[index]);
//                              } else if (snapshot.hasError) {
//                                return Text("${snapshot.error}");
//                              }
//
//                              // By default, show a loading spinner
//                              return CircularProgressIndicator();
//                            }),
                    ),
                    gridDelegate: SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
                        staggeredTileCount: snapshot.data.list.length,
                        maxCrossAxisExtent: 100.0,
                        mainAxisSpacing: 0.0,
                        crossAxisSpacing: 8.0,
                        staggeredTileBuilder: (index) => new StaggeredTile.fit(2)
                    ),
                  ),
                );
                else if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text("${snapshot.error}"),
                    ),
                  );
                }
                return SliverFillRemaining(
                  child: CircularProgressIndicator(),
                );
              }
          )
        ],
      ),
    );
  }
}


//class MyHomePage extends StatelessWidget {
//  MyHomePage() : _sizes = _createSizes(_kItemCount).toList();
//
//  static const int _kItemCount = 1000;
//  final List<IntSize> _sizes;
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: CustomScrollView(
//        slivers: <Widget>[
//          SliverAppBar(
//            title: Text("Say::Project"),
//            floating: true,
//            snap: true,
//          ),
//          SliverPadding(
//            padding: const EdgeInsets.all(12.0),
//            sliver: SliverStaggeredGrid(
//              delegate: SliverVariableSizeChildBuilderDelegate( (context, index) => new _Tile(index, snapshot.data.list[index]); ),
//              gridDelegate: SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
//                  maxCrossAxisExtent: 100.0,
//                  mainAxisSpacing: 0.0,
//                  crossAxisSpacing: 8.0,
//                  staggeredTileBuilder: (index) => new StaggeredTile.fit(2)
//              ),
//            ),
//          )
//        ],
//      ),
//    );
//  }
//}


//class Example08 extends StatelessWidget {
//  Example08() : _sizes = _createSizes(_kItemCount).toList();
//
//  static const int _kItemCount = 1000;
//  final List<IntSize> _sizes;
//
//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
//      appBar: new AppBar(
//        title: new Text('random dynamic tile sizes'),
//      ),
//      body: new StaggeredGridView.countBuilder(
//        primary: false,
//        crossAxisCount: 4,
//        mainAxisSpacing: 4.0,
//        crossAxisSpacing: 4.0,
//        itemBuilder: (context, index) => new _Tile(index, _sizes[index]),
//        staggeredTileBuilder: (index) => new StaggeredTile.fit(2),
//      ),
//    );
//  }
//}

class IntSize {
  const IntSize(this.width, this.height);

  final int width;
  final int height;
}

class _Tile extends StatelessWidget {
  const _Tile(this.index, this.size);

  final Post size;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          new Card(
            child: new Column(
              children: <Widget>[
                new Stack(
                  children: <Widget>[
                    //new Center(child: new CircularProgressIndicator()),
                    new Center(
                      child: new FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: size.image,
                      ),
//                      child: new Text(
//                        size.image,
//                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 25.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconTheme(
                    data: IconThemeData(
                        color: Colors.red,
                        opacity: 0.7,
                        size: 12.0
                    ),
                    child: Icon(Icons.favorite)
                ),
                SizedBox(width: 5.0,),
                Text("${size.upvote}", style: TextStyle(fontSize: 13.0, color: Colors.grey, fontWeight: FontWeight.bold),),
                SizedBox(width: 10.0,),
                IconTheme(
                    data: IconThemeData(
                        color: Colors.grey,
                        opacity: 0.7,
                        size: 12.0
                    ),
                    child: Icon(Icons.chat)
                ),
                SizedBox(width: 5.0,),
                Text("$index", style: TextStyle(fontSize: 13.0, color: Colors.grey, fontWeight: FontWeight.bold),),
              ],
            ),
          ),
//          Center(
//            child: Text(size.title),
//          )
        ]
    );
  }
}


//Center(
//child: FutureBuilder<Post>(
//future: fetchPost(),
//builder: (context, snapshot) {
//if (snapshot.hasData) {
//return Text(snapshot.data.title);
//} else if (snapshot.hasError) {
//return Text("${snapshot.error}");
//}
//
//// By default, show a loading spinner
//return CircularProgressIndicator();
//},
//),
//),