import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie_app/bloc/get_movie_videos_bloc.dart';
import 'package:movie_app/model/movie.dart';
import 'package:movie_app/model/video.dart';
import 'package:movie_app/model/video_response.dart';
import 'package:movie_app/screens/video_player.dart';
import 'package:movie_app/style/theme.dart' as Style;
import 'package:movie_app/widgets/casts.dart';
import 'package:movie_app/widgets/movie_info.dart';
import 'package:movie_app/widgets/similar_movies.dart';
import 'package:sliver_fab/sliver_fab.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  MovieDetailScreen({Key key, @required this.movie}) : super(key: key);
  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState(movie);
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final Movie movie;
  _MovieDetailScreenState(this.movie);

  @override
  void initState() {
    super.initState();
    movieVideoBloc..getMovieVideo(movie.id);
  }

  @override
  void dispose() {
    super.dispose();
    movieVideoBloc..drainStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      body: Builder(
        builder: (context) {
          return SliverFab(
            floatingPosition: FloatingPosition(right: 20),
            floatingWidget: StreamBuilder<VideoResponse>(
              stream: movieVideoBloc.subject.stream,
              builder: (context, AsyncSnapshot<VideoResponse> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.error != null &&
                      snapshot.data.error.length > 0) {
                    return _buildErrorWidget(snapshot.data.error);
                  }
                  return _buildVideoWidget(snapshot.data);
                } else if (snapshot.hasError) {
                  return _buildErrorWidget(snapshot.error);
                } else {
                  return _buildLoadingWidget();
                }
              },
            ),
            expandedHeight: 200,
            slivers: [
              SliverAppBar(
                backgroundColor: Style.Colors.mainColor,
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    movie.title.length > 40
                        ? movie.title.substring(0, 37) + '...'
                        : movie.title,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  background: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                                image: NetworkImage(
                                    "https://image.tmdb.org/t/p/original/" +
                                        movie.backPoster))),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5)),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                              Colors.black.withOpacity(0.9),
                              Colors.black.withOpacity(0.0)
                            ])),
                      )
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            movie.rating.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
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
                            initialRating: movie.rating / 2,
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
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 20),
                      child: Text(
                        "OVERVIEW",
                        style: TextStyle(
                            color: Style.Colors.titleColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        movie.overview,
                        style: TextStyle(
                            color: Colors.white, fontSize: 12, height: 1.5),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    MovieInfo(id: movie.id),
                    Casts(id: movie.id),
                    SimilarMovies(id: movie.id)
                  ]),
                ),
              )
            ],
          );
        },
      ),
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

  Widget _buildVideoWidget(VideoResponse data) {
    List<Video> videos = data.videos;
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(
                    controller: YoutubePlayerController(
                        initialVideoId: videos[0].key,
                        flags: YoutubePlayerFlags(
                          forceHD: true,
                          autoPlay: true)))));
      },
      backgroundColor: Style.Colors.secondColor,
      child: Icon(Icons.play_arrow),
    );
  }
}
