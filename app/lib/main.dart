import 'package:MoveisApp/pages/auth_page.dart';
import 'package:MoveisApp/pages/comments.dart';
import 'package:MoveisApp/pages/home_page.dart';
import 'package:MoveisApp/pages/movie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final _storage = FlutterSecureStorage();

  Future<String?> _readAccessToken() async {
    final storage = _storage;
    String? accessToken = await storage.read(key: 'access_token');
    return accessToken;
  }

  String? token = await _readAccessToken();

  bool isLoginUser = false;
  if (token != null && token != "") {
    isLoginUser = true;
  }

  runApp(MovieApp(isLoginUser: isLoginUser));
}

class MovieApp extends StatelessWidget {
  const MovieApp({
    Key? key,
    required this.isLoginUser,
  }) : super(key: key);

  final bool isLoginUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Test MoviesApp',
        theme: ThemeData.dark(),
        darkTheme: ThemeData(
            primaryColor: Colors.blueAccent,
            textTheme: TextTheme(
                bodyText1: TextStyle(
                    color: Color.fromARGB(255, 253, 253, 253), fontSize: 20),
                bodyText2: TextStyle(
                    color: Colors.red, fontSize: 16, fontFamily: 'Gilroy'),
                headline1: TextStyle(
                    color: Colors.white, fontSize: 30, fontFamily: 'Gilroy'),
                headline2: TextStyle(
                    color: Colors.white, fontSize: 25, fontFamily: 'Gilroy'),
                headline3: TextStyle(
                    color: Colors.white, fontSize: 20, fontFamily: 'Gilroy'),
                headline4: TextStyle(
                    color: Colors.white, fontSize: 15, fontFamily: 'Gilroy'),
                headline5: TextStyle(
                    color: Colors.white, fontSize: 10, fontFamily: 'Gilroy'),
                headline6: TextStyle(
                    color: Colors.white, fontSize: 5, fontFamily: 'Gilroy'))),
        routes: {
          '/home': (context) => HomePageWidget(),
          '/auth': (context) => AuthenticationPageWidget(),
          '/movie': (context) => MovieInformationWidget(),
          '/comments': (context) => CommentsWidget(),
        },
        initialRoute: isLoginUser ? '/home' : '/auth');
  }
}
