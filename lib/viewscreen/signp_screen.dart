import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:termproject/viewscreen/view/view_util.dart';

import '../controller/auth_controller.dart';
import '../model/constant.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signUpScreen';

  const SignUpScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUpScreen> {
  late _Controller con;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Text('Create a new account'),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Enter email'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: con.validateEmail,
                  onSaved: con.saveEmail,
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Enter password'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  obscureText: true,
                  validator: con.validatePass,
                  onSaved: con.savePass,
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Confirm password'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: con.validatePass,
                  onSaved: con.saveConfirmPass,
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: con.signup,
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _SignUpState state;
  _Controller(this.state);
  String? email;
  String? password;
  String? confirmPass;

  Future<void> signup() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;

    currentState.save();
    if (password != confirmPass) {
      showSnackBar(
          context: state.context,
          seconds: 20,
          message: 'Passwords do not match');

      return;
    }

    try {
      await AuthController.createAccount(email: email!, password: password!);
      showSnackBar(
          context: state.context,
          seconds: 20,
          message: 'Account Created! Sign in now');
    } catch (e) {
      if (Constant.devMode) print(' sign up failed : $e');
      showSnackBar(
          context: state.context, seconds: 20, message: 'Sign up failed : $e');
    }
  }

  String? validateEmail(String? value) {
    if (value == null || !(value.contains('@') && value.contains('.'))) {
      return 'Invalid Email';
    }
  }

  void saveEmail(String? value) {
    email = value;
  }

  String? validatePass(String? value) {
    if (value == null || value.length < 6) {
      return 'Invalid Password';
    } else
      return null;
  }

  void savePass(String? value) {
    password = value;
  }

  void saveConfirmPass(String? value) {
    confirmPass = value;
  }
}
