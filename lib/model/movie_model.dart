class Person {
  late String name;
  late String avatarURL;

  Person.fromMap(Map<String, dynamic> json) {
    name = json["name"];
    avatarURL = json["avatars"]["medium"];
  }
}

class Actor extends Person {
  Actor.fromMap(Map<String, dynamic> json): super.fromMap(json);
}

class Director extends Person {
  Director.fromMap(Map<String, dynamic> json): super.fromMap(json);
}

int counter = 1;

class MovieItem {
  late int rank;
  late String imageURL;
  late String title;
  late String language;
  late String playDate;
  late String rating;
  late String genre;
  late String originalTitle;

  MovieItem.fromMap(Map<String, dynamic> json) {
    rank = counter++;
    imageURL = json["data"][0]["poster"];
    title = json["data"][0]["name"];
    playDate = json["year"];
    rating = json["doubanRating"];
    genre = json["data"][0]["genre"];
    language = json["data"][0]["language"];
    originalTitle = json["originalName"];
  }
}