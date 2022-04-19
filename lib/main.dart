import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:termproject/viewscreen/addphotomemo_screen.dart';
import 'package:termproject/viewscreen/detailedview_screen.dart';
import 'package:termproject/viewscreen/error_screen.dart';
import 'package:termproject/viewscreen/friend_screen.dart';
import 'package:termproject/viewscreen/sharedwith_screen.dart';
import 'package:termproject/viewscreen/signp_screen.dart';
import 'package:termproject/viewscreen/start_screen.dart';
import 'package:termproject/viewscreen/userhome_screen.dart';

import 'model/constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: Constant.devMode,
      initialRoute: StartScreen.routeName,
      routes: {
        StartScreen.routeName: (context) => const StartScreen(),
        UserHomeScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return ErrorScreen('args is null for UserHomeScreen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var photoMemoList = argument[ArgKey.photoMemoList];
            return UserHomeScreen(
              user: user,
              photoMemoList: photoMemoList,
            );
          }
        },
        AddPhotoMemoScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return ErrorScreen('args is null for AddPhotoMemoScreen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var photoMemoList = argument[ArgKey.photoMemoList];
            return AddPhotoMemoScreen(
              user: user,
              photoMemoList: photoMemoList,
            );
          }
        },
        DetailedViewScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return ErrorScreen('args is null for DetailedViewScreen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var photoMemo = argument[ArgKey.onePhotoMemo];
            return DetailedViewScreen(
              user: user,
              photoMemo: photoMemo,
            );
          }
        },
        SignUpScreen.routeName: (context) => const SignUpScreen(),
        FriendScreen.routeName: (context) => const FriendScreen(),
        SharedWithScreen.routeName: (context) {
          print("OK");
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return ErrorScreen('args is null for AdSharedWithoScreen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var photoMemoList = argument[ArgKey.photoMemoList];
            return SharedWithScreen(
              user: user,
              photoMemoList: photoMemoList,
            );
          }
        },
      },
    );
  }
}
