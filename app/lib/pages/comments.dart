import 'package:MoveisApp/classes/comment.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CommentsWidget extends StatefulWidget {
  CommentsWidget({Key? key}) : super(key: key);

  @override
  State<CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  Future<String?> _readAccessToken() async {
    final storage = FlutterSecureStorage();
    String? accessToken = await storage.read(key: 'access_token');
    return accessToken;
  }

  InputDecoration getInputDecoration() {
    return InputDecoration(
      enabled: true,
      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: Color.fromRGBO(229, 228, 228, 1), width: 2)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Color.fromRGBO(229, 228, 228, 1),
            width: 2,
          )),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: Color.fromRGBO(229, 228, 228, 1), width: 2)),
    );
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

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map;
    final movieID = arguments["movieID"];

    Future<List<_CommentWidget>> getCommentsVideo() async {
      var dio = Dio();
      String? accessToken = await _readAccessToken();

      Response response = await dio.get(
          'https://sarzhevsky.com/movies-api/Movies/$movieID/Comments',
          options: Options(headers: {
            "Authorization": "Bearer $accessToken",
          }, responseType: ResponseType.json));

      print(response.data.toString());

      List<_CommentWidget> listComments = [];

      for (var element in response.data) {
        listComments.add(_CommentWidget(
            comment: Comment(
                id: int.parse(element['id'].toString()),
                message: element['message'].toString())));
      }

      return listComments;
    }

    final Future<List<_CommentWidget>> getCommentsLoader =
        Future<List<_CommentWidget>>.delayed(
            const Duration(seconds: 2), () => getCommentsVideo());

    return Scaffold(
      appBar: AppBar(title: Text('Information about movie')),
      body: FutureBuilder<List<_CommentWidget>>(
          future: getCommentsLoader,
          builder: (BuildContext context,
              AsyncSnapshot<List<_CommentWidget>> snapshot) {
            TextEditingController commentUserController =
                TextEditingController();
            List<_CommentWidget> comments = snapshot.data ?? [];

            Future<void> _sendComment() async {
              var dio = Dio();
              var params = {
                "id": movieID,
                "message": commentUserController.text
              };
              String? accessToken = await _readAccessToken();
              try {
                Response response = await dio.post(
                    'https://sarzhevsky.com/movies-api/Movies/$movieID/Comments/Post',
                    data: params,
                    options: Options(
                        headers: {'Authorization': 'Bearer $accessToken'}));
                List<_CommentWidget> newComments = comments;
                newComments.insert(
                    0,
                    _CommentWidget(
                      comment: Comment(
                          id: int.parse(response.data['id'].toString()),
                          message: response.data['message'].toString()),
                    ));
                setState(() {
                  comments = newComments;
                });
              } on DioError catch (error) {
                print(error);
                if (error.response?.statusCode == 401) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/auth', (Route<dynamic> route) => false);
                }
              }
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  height: 600,
                  child: ListView(
                    children: [
                      SizedBox(
                          height: 100,
                          child: TextField(
                              keyboardType: TextInputType.multiline,
                              maxLength: 2000,
                              maxLines: null,
                              controller: commentUserController,
                              decoration: getInputDecoration())),
                      ElevatedButton(
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 78, right: 78, top: 15, bottom: 15),
                            child: const Text('Send comment',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 19),
                                textAlign: TextAlign.center),
                          ),
                          onPressed: _sendComment,
                          style: _buttonStyleWidget()),
                      SizedBox(height: 20),
                      Center(
                          child: Text('COMMENTS',
                              style: Theme.of(context).textTheme.headline5)),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(children: comments),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
    ;
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
