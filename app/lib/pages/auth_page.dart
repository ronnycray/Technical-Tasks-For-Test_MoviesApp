import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthenticationPageWidget extends StatefulWidget {
  AuthenticationPageWidget({Key? key}) : super(key: key);

  @override
  State<AuthenticationPageWidget> createState() =>
      _AuthenticationPageWidgetState();
}

class _AuthenticationPageWidgetState extends State<AuthenticationPageWidget> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  final _storage = FlutterSecureStorage();

  String? loginError;
  String? passwordError;

  @override
  Widget build(BuildContext context) {
    InputDecoration getInputDecoration(String? errorText, String? hintText) {
      return InputDecoration(
          enabled: true,
          errorText: errorText,
          hintText: hintText,
          errorStyle: Theme.of(context).textTheme.bodyText2,
          contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: Color.fromRGBO(229, 228, 228, 1), width: 1)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Color.fromRGBO(229, 228, 228, 1),
                width: 1,
              )),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Color.fromRGBO(229, 228, 228, 1),
                width: 1,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: Color.fromRGBO(229, 228, 228, 1), width: 1)));
    }

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

    Future<void> _pushButtonLogin() async {
      final loginIsEmpty = loginController.text.isEmpty;
      final passwordIsEmpty = passwordController.text.isEmpty;

      setState(() {
        loginError = '';
        passwordError = '';
      });

      if (loginIsEmpty) {
        setState(() {
          loginError = 'Field is empty';
        });
      }

      if (passwordIsEmpty) {
        setState(() {
          passwordError = 'Field is empty';
        });
      }

      if (!loginIsEmpty && !passwordIsEmpty) {
        var dio = Dio();
        var params = {
          "username": "dale@appcreative.com",
          "password": "Udt9TzzPwnednVV4",
          "grant_type": "password"
        };
        try {
          Response response = await dio.post(
            'https://sarzhevsky.com/movies-api/Login',
            data: params,
          );
          await _storage.write(
              key: 'access_token', value: response.data['access_token']);
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        } on Exception catch (_) {
          print('ERROR AUTH');
        }
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
            child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: Column(
            children: [
              SizedBox(height: 250),
              Center(
                  child: Text(
                'Authentication MoviesApp',
                style: TextStyle(fontSize: 25),
              )),
              SizedBox(height: 50),
              SizedBox(
                height: 60,
                child: TextField(
                    controller: loginController,
                    decoration:
                        getInputDecoration(loginError, 'Username / Email')),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 60,
                child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: getInputDecoration(passwordError, 'Password')),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 78, right: 78, top: 15, bottom: 15),
                    child: const Text('Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.normal,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  onPressed: _pushButtonLogin,
                  style: _buttonStyleWidget())
            ],
          ),
        )),
      ),
    );
  }
}
