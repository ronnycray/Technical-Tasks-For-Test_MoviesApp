import 'package:MoveisApp/classes/movie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePageWidget extends StatefulWidget {
  HomePageWidget({Key? key}) : super(key: key);

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final _storage = FlutterSecureStorage();
  String videoTitle = "Video title";
  List<_MovieWidget> listMovies = [];

  Future<String?> _readAccessToken() async {
    final storage = _storage;
    String? accessToken = await storage.read(key: 'access_token');
    return accessToken;
  }

  Future<List<_MovieWidget>> getMovieList() async {
    var dio = Dio();
    String? accessToken = await _readAccessToken();

    Response response =
        await dio.get('https://sarzhevsky.com/movies-api/Movies',
            options: Options(headers: {
              "Authorization": "Bearer $accessToken",
            }, responseType: ResponseType.json));

    List<Movie> resultList = [];
    for (var elemnt in response.data) {
      resultList.add(Movie(
        id: int.parse(elemnt['id'].toString()),
        title: elemnt['title'].toString(),
        posterImage: elemnt['posterUrl'].toString(),
        year: elemnt['year'].toString(),
        duration: elemnt['duration'].toString(),
        rating: elemnt['rating'].toString(),
      ));
    }

    List<_MovieWidget> listMovieWidget = [];

    for (var movie in resultList) {
      listMovies.add(_MovieWidget(
        id: movie.id,
        videoTitle: movie.title,
        posterImage: movie.posterImage,
        year: movie.year,
        duration: movie.duration,
        rating: movie.rating,
      ));
    }

    return listMovieWidget;
  }

  Future<void> logut() async {
    final storage = _storage;
    await storage.delete(key: 'access_token');
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/auth', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final Future<List<_MovieWidget>> _loader =
        Future<List<_MovieWidget>>.delayed(
            const Duration(seconds: 2), () => getMovieList());

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 150),
              SizedBox(
                width: 150,
                child: Text('Movies'),
              ),
              GestureDetector(
                onTap: () {
                  logut();
                },
                child: SizedBox(
                  width: 50,
                  child: Icon(Icons.logout),
                ),
              )
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<_MovieWidget>>(
          future: _loader,
          builder: (BuildContext context,
              AsyncSnapshot<List<_MovieWidget>> snapshot) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Container(
                      child: Column(
                        children: snapshot.hasData
                            ? listMovies
                            : [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Finding movies'),
                                    SizedBox(width: 5),
                                    Icon(Icons.search)
                                  ],
                                )
                              ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class _MovieWidget extends StatelessWidget {
  const _MovieWidget(
      {Key? key,
      required this.id,
      required this.videoTitle,
      required this.posterImage,
      required this.year,
      required this.duration,
      required this.rating})
      : super(key: key);

  final int id;
  final String videoTitle;
  final String posterImage;
  final String year;
  final String duration;
  final String rating;

  @override
  Widget build(BuildContext context) {
    void showMovieInformation(int movieID) {
      Navigator.of(context)
          .pushNamed('/movie', arguments: {'movieID': movieID});
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
      child: GestureDetector(
        onTap: () {
          showMovieInformation(id);
        },
        child: SizedBox(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      width: 170,
                      height: 270,
                      child: Image.network(posterImage)),
                  Container(
                    width: 170,
                    height: 270,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              videoTitle,
                              style: Theme.of(context).textTheme.headline5,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_today_sharp),
                                SizedBox(width: 4),
                                Text(year)
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.av_timer_sharp),
                                  SizedBox(width: 4),
                                  Text('Duration:'),
                                  SizedBox(width: 4),
                                  Text(duration),
                                ]),
                          ),
                          SizedBox(height: 10),
                          Container(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.star),
                                  SizedBox(width: 4),
                                  Text('Rating:'),
                                  SizedBox(width: 4),
                                  Text(rating)
                                ]),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
