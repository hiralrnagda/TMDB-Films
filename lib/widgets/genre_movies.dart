import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie_app/bloc/get_movies_byGenre_bloc.dart';
import 'package:movie_app/model/movie.dart';
import 'package:movie_app/model/movie_response.dart';
import 'package:movie_app/screens/detail_screen.dart';
import 'package:movie_app/style/theme.dart' as Style;

class GenreMovies extends StatefulWidget {
  final int genreId;
  GenreMovies({Key key, @required this.genreId}) : super(key: key);
  @override
  _GenreMoviesState createState() => _GenreMoviesState(genreId);
}

class _GenreMoviesState extends State<GenreMovies> {
  final int genreId;
  _GenreMoviesState(this.genreId);

  @override
  void initState() {
    super.initState();
    moviesByGenreBloc..getMoviesByGenre(genreId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MovieResponse>(
        stream: moviesByGenreBloc.subject.stream,
        builder: (context, AsyncSnapshot<MovieResponse> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.error != null && snapshot.data.error.length > 0) {
              return _buildErrorWidget(snapshot.data.error);
            }
            return _buildMoviesByGenreWidget(snapshot.data);
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error);
          } else {
            return _buildLoadingWidget();
          }
        });
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 25,
            width: 25,
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 4.0,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Error occured: $error"),
      ],
    ));
  }

  Widget _buildMoviesByGenreWidget(MovieResponse data) {
    List<Movie> movies = data.movies;
    if (movies.length == 0) {
      return Container(
        child: Text("No Movies"),
      );
    } else {
      return Container(
        height: 270,
        padding: EdgeInsets.only(left: 10),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: movies.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MovieDetailScreen(movie: movies[index])));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    movies[index].poster == null
                        ? Container(
                            width: 120,
                            height: 180,
                            decoration: BoxDecoration(
                                color: Style.Colors.secondColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2)),
                                shape: BoxShape.rectangle),
                            child: Column(
                              children: [
                                Icon(
                                  EvaIcons.filmOutline,
                                  color: Colors.white,
                                  size: 50,
                                )
                              ],
                            ),
                          )
                        : Container(
                            height: 180,
                            width: 120,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2)),
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                    image: NetworkImage(
                                        "https://image.tmdb.org/t/p/w200/" +
                                            movies[index].poster),
                                    fit: BoxFit.cover)),
                          ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 100,
                      child: Text(
                        movies[index].title,
                        maxLines: 2,
                        style: TextStyle(
                            height: 1.4,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text(
                          movies[index].rating.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        RatingBar.builder(
                          itemBuilder: (context, _) => Icon(
                            EvaIcons.star,
                            color: Style.Colors.secondColor,
                          ),
                          initialRating: movies[index].rating / 2,
                          itemSize: 8,
                          minRating: 1,
                          direction: Axis.horizontal,
                          itemCount: 5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 2),
                          allowHalfRating: true,
                          onRatingUpdate: (rating) {
                            print(rating);
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
