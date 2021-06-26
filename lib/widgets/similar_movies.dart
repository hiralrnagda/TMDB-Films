import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie_app/bloc/get_movie_similar_bloc.dart';
import 'package:movie_app/model/movie.dart';
import 'package:movie_app/model/movie_response.dart';
import 'package:movie_app/style/theme.dart' as Style;

class SimilarMovies extends StatefulWidget {
  final int id;
  SimilarMovies({Key key, @required this.id}) : super(key: key);
  @override
  _SimilarMoviesState createState() => _SimilarMoviesState(id);
}

class _SimilarMoviesState extends State<SimilarMovies> {
  final int id;
  _SimilarMoviesState(this.id);
  @override
  void initState() {
    super.initState();
    similarMovieBloc..getSimilarMovies(id);
  }

  @override
  void dispose(){
    super.dispose();
    similarMovieBloc..drainStream();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10, top: 20),
          child: Text(
            'SIMILAR MOVIES',
            style: TextStyle(
                color: Style.Colors.titleColor,
                fontWeight: FontWeight.w500,
                fontSize: 12),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        StreamBuilder<MovieResponse>(
            stream: similarMovieBloc.subject.stream,
            builder: (context, AsyncSnapshot<MovieResponse> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.error != null &&
                    snapshot.data.error.length > 0) {
                  return _buildErrorWidget(snapshot.data.error);
                }
                return _buildMoviesWidget(snapshot.data);
              } else if (snapshot.hasError) {
                return _buildErrorWidget(snapshot.error);
              } else {
                return _buildLoadingWidget();
              }
            })
      ],
    );
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

  Widget _buildMoviesWidget(MovieResponse data) {
    List<Movie> movies = data.movies;
    if (movies.length == 0) {
      return Center(
        child: Container(
          child: Text("No Similar Movies",style: TextStyle(color: Colors.white),),
        ),
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
              child: Column(
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
            );
          },
        ),
      );
    }
  }
}
