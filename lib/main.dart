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
  await http.get('http://192.168.0.18:8000/API/articles/?format=json');
//  var completer = new Completer();

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
  int upvote;
  String title;
  String image;

  Post({this.upvote, this.title, this.image});

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
      home: new SayProject(),
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
  List<Post> listPo = new List();
  int _page = 0;
//
//  _SayProjectState() {
//    fetchPost().then((value) => setState(() {
//      postList = value;
//    }));
//  }
  void _incrementPage() {
    setState(() {
      _page++;
    });
  }

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    fetch();
    _incrementPage();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        fetch();
        _incrementPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            title: Center(child: Text("Say::Project", style: TextStyle(color: Colors.black),)),
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12.0),
            sliver: SliverStaggeredGrid(
              delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                  new _Tile(index, listPo[index])
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
                  staggeredTileCount: listPo.length,
                  maxCrossAxisExtent: 100.0,
                  mainAxisSpacing: 0.0,
                  crossAxisSpacing: 8.0,
                  staggeredTileBuilder: (index) => new StaggeredTile.fit(2)
              ),
            ),
          ),
        ],
      ),
    );
  }

  fetch() async {
    final response =
//  await http.get('https://jsonplaceholder.typicode.com/posts/1');
    await http.get('http://192.168.0.18:8000/API/articles/?format=json&limit=5&offset=${_page*5}');
//  var completer = new Completer();
    int count = json.decode(response.body)['count'];

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
//    print(json.decode(response.body));
//    print(json.decode(response.body).length);
//    for (var test in json.decode(response.body)) {
//      print(test['title']);
//    }

//      print(response.body);

//      print(json.decode(response.body)[0]['image']);

      setState(() {
        for (int i =0; i < min(5, count - (_page-1)*5); i++) {
          var temp = json.decode(response.body);
          var Posts = new Post(image: temp['results'][i]['image'],
              upvote: temp['results'][i]['upvote'],
              title: temp['results'][i]['title']);
          listPo.add(Posts);
        }
      });
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

}


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
          new Container(
//            shape: RoundedRectangleBorder(
//              borderRadius: BorderRadius.circular(10.0),
//            ),
//            clipBehavior: Clip.antiAlias,
//            decoration: new BoxDecoration(
//              borderRadius: new BorderRadius.all(
//                Radius.circular(10.0)
//              )
//            ),
            padding: EdgeInsets.all(5.0),
            child:
            new Stack(
              children: <Widget>[
                //new Center(child: new CircularProgressIndicator()),
                GestureDetector(
                  onTap : () {
                    final snackBar = new SnackBar(content: Text("눌렀서요!!"));

                    Scaffold.of(context).showSnackBar(snackBar);
                  },
//                      child: new FadeInImage.memoryNetwork(
//                        placeholder: kTransparentImage,
//                        image: size.image,
//                      ),
                  child: new ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: new FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: size.image,
                    ),
                  ),
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
                SizedBox(width: 4.0,),
                Text("${size.upvote}", style: TextStyle(fontSize: 9.0, color: Colors.grey, fontWeight: FontWeight.bold),),
                SizedBox(width: 10.0,),
                IconTheme(
                    data: IconThemeData(
                        color: Colors.grey,
                        opacity: 0.7,
                        size: 12.0
                    ),
                    child: Icon(Icons.chat)
                ),
                SizedBox(width: 4.0,),
                Text("$index", style: TextStyle(fontSize: 9.0, color: Colors.grey, fontWeight: FontWeight.bold),),
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
