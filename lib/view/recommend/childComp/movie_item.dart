import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reading/model/movie_model.dart';

class MovieListItem extends StatelessWidget {
  final MovieItem item;
  const MovieListItem(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(width: 10, color: Colors.grey.shade300))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getRankWidget(),
            const SizedBox(
              height: 10,
            ),
            getMovieContent(),
            const SizedBox(
              height: 10,
            ),
            getOriginalName(),
          ],
        ));
  }

  Widget getMovieContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        getMovieImg(),
        const SizedBox(
          width: 10,
        ),
        Expanded(child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            getMovieInfo(),
            const SizedBox(
              height: 10,
            ),
            getGenreWidget(),
          ]),
        )),
        const SizedBox(
          width: 10,
        ),
        getWishWidget(),
      ],
    );
  }

  Widget getMovieImg() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Image.network(
        item.imageURL,
        height: 150,
      ),
    );
  }

  Widget getMovieInfo() {
    return Stack(
      children: [
        const Icon(
          Icons.play_circle_outline,
          color: Colors.red,
          size: 28,
        ),
        Text.rich(TextSpan(children: [
          TextSpan(
              text: "       ${item.title}",
              style: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold)),
          TextSpan(
              text: "(${item.playDate})", style: TextStyle(fontSize: 18, color: Colors.black87)),
        ])),
      ],
    );
  }

  Widget getGenreWidget(){
    return Text("${item.language} / ${item.genre}", style: TextStyle(fontSize: 16,color: Colors.black54));
  }

  Widget getWishWidget() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
        child: Column(children: const [
          Icon(
            Icons.favorite_border,
            color: Color.fromARGB(255, 255, 166, 2),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "想看",
            style: TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 255, 166, 2),
                fontWeight: FontWeight.bold),
          ),
        ]));
  }

  Widget getRankWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 238, 205, 144),
          borderRadius: BorderRadius.circular(3)),
      child: Text(
        "NO.${item.rank}",
        style: const TextStyle(
            color: Color.fromARGB(255, 131, 95, 36), fontSize: 18),
      ),
    );
  }

  Widget getOriginalName() {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
          color: const Color(0xffeeeeee),
          borderRadius: BorderRadius.circular(5)),
      child: Text(
        item.originalTitle,
        style: const TextStyle(color: Colors.black54, fontSize: 18),
      ),
    );
  }
}
