import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:termproject/controller/auth_controller.dart';
import 'package:termproject/controller/firestore_controller.dart';
import 'package:termproject/model/constant.dart';
import 'package:termproject/model/photo_memo.dart';
//import java.util.*;
import 'package:termproject/viewscreen/signp_screen.dart';
import 'package:termproject/viewscreen/userhome_screen.dart';
import 'package:termproject/viewscreen/view/view_util.dart';

class StartScreen extends StatefulWidget {
  static const routeName = '/startScreen';

  const StartScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _StartState();
  }
}

class _StartState extends State<StartScreen> {
  late _Controller con;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'PhotoMemo',
                style: Theme.of(context).textTheme.headline3,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Email Address',
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: con.validateEmail,
                onSaved: con.saveEmail,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Password',
                ),
                //keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                obscureText: true,
                validator: con.validatePassword,
                onSaved: con.savePassword,
              ),
              ElevatedButton(
                onPressed: con.signin,
                child: Text(
                  'Sign in',
                  style: Theme.of(context).textTheme.button,
                ),
              ),
              const SizedBox(height: 24.0),
              OutlinedButton(
                  onPressed: con.signUp, child: Text('Create Account')),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _StartState state;
  String? email;
  String? password;

  _Controller(this.state);

  Future<void> signin() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    if (!currentState.validate()) return;
    currentState.save();

    startCircularProgress(state.context);

    User? user;
    try {
      if (email == null || password == null) {
        throw 'Email or Pasword is Null';
      }
      user = await AuthController.signin(email: email!, password: password!);

      List<PhotoMemo> photoMemoList =
          await FirestoreController.getPhotoMemoList(email: email!);

      print(photoMemoList.length);
      //print('AFFFFFFFFF');

      stopCircularProgress(state.context);

      Navigator.pushNamed(
        state.context,
        UserHomeScreen.routeName,
        arguments: {
          ArgKey.user: user,
          ArgKey.photoMemoList: photoMemoList,
        },
      );
      print('================ user: $user');
      print('$photoMemoList');
    } catch (e) {
      stopCircularProgress(state.context);
      if (Constant.devMode) print('*********** Sign in ErrorL $e');
      showSnackBar(
          context: state.context, seconds: 20, message: 'Sign in Error : $e');
    }
  }

  String? validateEmail(String? value) {
    if (value == null) {
      return 'No email provided';
    } else if (!(value.contains('@')) && value.contains('.')) {
      return 'Invalid email format';
    } else {
      return null;
    }
  }

  void saveEmail(String? value) {
    if (value != null) {
      email = value;
    }
  }

  String? validatePassword(String? value) {
    if (value == null) {
      return 'password not provided';
    } else if (value.length < 6) {
      return 'password too short';
    } else {
      return null;
    }
  }

  void savePassword(String? value) {
    if (value != null) {
      password = value;
    }
  }

  void signUp() {
    Navigator.pushNamed(state.context, SignUpScreen.routeName);
  }
}
