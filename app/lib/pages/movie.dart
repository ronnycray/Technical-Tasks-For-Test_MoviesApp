import 'package:MoveisApp/classes/cast.dart';
import 'package:MoveisApp/classes/comment.dart';
import 'package:MoveisApp/classes/info_movie.dart';
import 'package:MoveisApp/classes/movie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MovieInformationWidget extends StatefulWidget {
  const MovieInformationWidget({Key? key}) : super(key: key);

  @override
  State<MovieInformationWidget> createState() => _MovieInformationWidgetState();
}

class _MovieInformationWidgetState extends State<MovieInformationWidget> {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map;
    final movieID = arguments["movieID"];

    Future<String?> _readAccessToken() async {
      final storage = FlutterSecureStorage();
      String? accessToken = await storage.read(key: 'access_token');
      return accessToken;
    }

    Future<_InformationMovieWidget> getInformationMovie(int movieID) async {
      var dio = Dio();
      String? accessToken = await _readAccessToken();

      Response responseInfo = await dio.get(
          'https://sarzhevsky.com/movies-api/Movies/$movieID/Info',
          options: Options(headers: {
            "Authorization": "Bearer $accessToken",
          }, responseType: ResponseType.json));

      MovieInformation movieInfo = MovieInformation(
          movie: Movie(
              id: int.parse(responseInfo.data['id'].toString()),
              title: responseInfo.data['title'].toString(),
              duration: responseInfo.data['duration'].toString(),
              year: responseInfo.data['year'].toString(),
              rating: responseInfo.data['rating'].toString(),
              posterImage: responseInfo.data['posterUrl'].toString()),
          casts: []);

      Response responseCast = await dio.get(
          'https://sarzhevsky.com/movies-api/Movies/$movieID/Cast',
          options: Options(headers: {
            "Authorization": "Bearer $accessToken",
          }, responseType: ResponseType.json));

      for (var element in responseCast.data) {
        movieInfo.casts.add(Cast(fullName: element));
      }

      return _InformationMovieWidget(movieInfo: movieInfo);
    }

    final Future<_InformationMovieWidget> _loader =
        Future<_InformationMovieWidget>.delayed(
            const Duration(seconds: 2), () => getInformationMovie(movieID));

    return Scaffold(
      appBar: AppBar(title: Text('Information about movie')),
      body: FutureBuilder<_InformationMovieWidget>(
        future: _loader,
        builder: (BuildContext context,
            AsyncSnapshot<_InformationMovieWidget> snapshot) {
          return SingleChildScrollView(
            child: Column(children: [
              Center(
                child: Center(
                  child: snapshot.data ??
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Text('Awaiting result...'),
                              )
                            ],
                          )),
                ),
              )
            ]),
          );
        },
      ),
    );
  }
}

class _InformationMovieWidget extends StatefulWidget {
  const _InformationMovieWidget({Key? key, required this.movieInfo})
      : super(key: key);

  final MovieInformation movieInfo;

  @override
  State<_InformationMovieWidget> createState() =>
      _InformationMoviwWidgetState();
}

class _InformationMoviwWidgetState extends State<_InformationMovieWidget> {
  List<_CommentWidget> comments = [];

  @override
  Widget build(BuildContext context) {
    ButtonStyle _buttonStyleWidget() {
      return ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        backgroundColor:
            MaterialStateProperty.all(const Color.fromRGBO(56, 255, 139, 0.7)),
        shadowColor: MaterialStateProperty.all(Colors.transparent),
      );
    }

    void _showModalCommentsWidget() {
      Navigator.of(context).pushNamed('/comments',
          arguments: {'movieID': widget.movieInfo.movie.id});
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Center(
        child: Container(
          child: Column(
            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 200,
                        height: 300,
                        child:
                            Image.network(widget.movieInfo.movie.posterImage)),
                    SizedBox(height: 20),
                    Container(
                        child: Text(
                      widget.movieInfo.movie.title,
                      style: Theme.of(context).textTheme.headline4,
                      textAlign: TextAlign.center,
                    )),
                    SizedBox(height: 10),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Release date',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(width: 5),
                          Text(
                            widget.movieInfo.movie.year,
                            style: Theme.of(context).textTheme.headline6,
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Duration',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(width: 5),
                          Text(
                            widget.movieInfo.movie.duration,
                            style: Theme.of(context).textTheme.headline6,
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Rating',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(width: 5),
                          Text(
                            widget.movieInfo.movie.rating,
                            style: Theme.of(context).textTheme.headline6,
                          )
                        ],
                      ),
                    ),
                  ]),
              SizedBox(
                height: 40,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Casts of movie:',
                      style: Theme.of(context).textTheme.headline5),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.movieInfo.casts
                        .map((e) => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.person),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(e.fullName,
                                    style:
                                        Theme.of(context).textTheme.headline6),
                              ],
                            ))
                        .toList(),
                  )
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 78, right: 78, top: 15, bottom: 15),
                    child: const Text('Show comments',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.normal,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  onPressed: _showModalCommentsWidget,
                  style: _buttonStyleWidget())
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentWidget extends StatefulWidget {
  _CommentWidget({Key? key, required this.comment}) : super(key: key);

  final Comment comment;

  @override
  State<_CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<_CommentWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 36, 36, 36),
            borderRadius: BorderRadius.all(Radius.circular(2))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text('From: Anonimys',
                    style: Theme.of(context).textTheme.headline5),
              ),
              SizedBox(height: 10),
              Container(
                child: Text(
                  widget.comment.message,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }
}
