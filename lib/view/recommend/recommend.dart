import 'package:flutter/material.dart';
import '/network/http_request.dart';
import '/model/movie_model.dart';

class Recommend extends StatelessWidget {
  const Recommend({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('推荐书籍')), body: const RecommendBode());
  }
}

class RecommendBode extends StatefulWidget {
  const RecommendBode({Key? key}) : super(key: key);

  @override
  RecommendBodeState createState() => RecommendBodeState();
}

class RecommendBodeState extends State<RecommendBode> {
  List<MovieItem> movies = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getMovieList();
  }

  getMovieList() async {
    final result =
        await HttpRequest.request("/top?type=Imdb&skip=0&limit=20&lang=Cn");
    for (var sub in result) {
      setState(() {
        movies.add(MovieItem.fromMap(sub));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) => ListTile(
                  title: Text(movies[index].title),
                  subtitle: Text("上映时间: ${movies[index].playDate}"),
                  leading: Image.network(movies[index].imageURL),
                  trailing: Text(movies[index].rating),
                )));
  }
}
