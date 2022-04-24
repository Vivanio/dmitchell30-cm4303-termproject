import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:termproject/model/friend.dart';

import '../controller/cloudstorage_controller.dart';
import '../controller/firestore_controller.dart';
import '../controller/ml_controller.dart';
import '../model/constant.dart';
import 'view/view_util.dart';

class AddFriendScreen extends StatefulWidget {
  final User user;
  final List<Friend> friendList;
  static const routeName = '/addFriendScreen';

  const AddFriendScreen(
      {required this.user, required this.friendList, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AddFriendState();
  }
}

class _AddFriendState extends State<AddFriendScreen> {
  late _Controller con;
  var formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Friend'),
        actions: [
          IconButton(onPressed: con.save, icon: const Icon(Icons.check))
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(hintText: 'Add Friend Email Here'),
                autocorrect: true,
                keyboardType: TextInputType.emailAddress,
                maxLines: 1,
                validator: Friend.validateEmail,
                onSaved: con.saveEmail,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _AddFriendState state;
  _Controller(this.state);

  Friend tempFriend = Friend();

  void saveEmail(String? value) {
    if (value != null) {
      tempFriend.user = value;
    }
  }

  Future<void> save() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) {
      return;
    }
    currentState.save();

    //startCircularProgress(state.context);

    try {
      String docId = await FirestoreController.addFriend(friend: tempFriend);
      tempFriend.docId = docId;
      List<Friend> photoMemoList =
          await FirestoreController.getFriend(email: state.widget.user.email!);

      state.widget.friendList.add(tempFriend);

      //stopCircularProgress(state.context);

      Navigator.of(state.context).pop();
      Navigator.of(state.context).pop();
      Navigator.of(state.context).pop();
      state.render(() {});

      print('=============== docId: $docId');
    } catch (e) {
      //stopCircularProgress(state.context);
      if (Constant.devMode) print('****** uploadFIle/Doc error: $e');
      showSnackBar(
          context: state.context,
          seconds: 20,
          message: '****** uploadFIle/Dggoc error: $e');
    }
  }
}
