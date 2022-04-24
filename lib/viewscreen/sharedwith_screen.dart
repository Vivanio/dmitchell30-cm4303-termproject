//import 'dart:js';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:termproject/viewscreen/view/view_util.dart';
import 'package:termproject/viewscreen/view/webimage.dart';

import '../controller/firestore_controller.dart';
import '../model/constant.dart';
import '../model/friend.dart';
import '../model/photo_memo.dart';

class SharedWithScreen extends StatefulWidget {
  static const routeName = '/sharedWithScreen';

  final List<PhotoMemo> photoMemoList;
  final User user;
  //final PhotoMemo photoMemo;
  const SharedWithScreen({
    required this.user,
    required this.photoMemoList,
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SharedScreenState();
  }
}

class _SharedScreenState extends State<SharedWithScreen> {
  late _Controller con;
  //int index = 0;
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
        title: Text('Shared With : ${widget.user.email}'),
      ),
      body: Form(
        key: formKey,
        child: widget.photoMemoList.isEmpty
            ? const Text('No PhotoMemo shared')
            : ListView.builder(
                itemCount: con.photoMemoList.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: WebImage(
                              url: con.photoMemoList[index].photoURL,
                              context: context,
                              height: MediaQuery.of(context).size.height * 0.3,
                            ),
                          ),
                          Text(
                            con.photoMemoList[index].title,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Text(con.photoMemoList[index].memo),
                          Text(
                              'Created By: ${con.photoMemoList[index].createBy}'),
                          Text(
                              'Created at: ${con.photoMemoList[index].timestamp}'),
                          Text(
                              ' Shared With: ${con.photoMemoList[index].sharedWith}'),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Add comment?',
                              fillColor: Color.fromARGB(255, 206, 201, 201),
                              filled: true,
                            ),
                            autocorrect: true,
                            validator: Friend.validateComment,
                            onSaved: con.saveComment,
                          ),
                          ElevatedButton(
                            onPressed: con.updateComment,
                            child: Text(
                              'Upload Comment',
                              style: Theme.of(context).textTheme.button,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _Controller {
  late _SharedScreenState state;
  List<int> selected = [];
  late List<PhotoMemo> photoMemoList;
  late String? userComment = '';
  late String? userName = state.widget.user.email;
  late String? tempString = '';
  int index = 0;
  late PhotoMemo tempMemo;

  _Controller(this.state) {
    photoMemoList = state.widget.photoMemoList;
    tempMemo = PhotoMemo.clone(state.widget.photoMemoList[index]);
  }

  void saveComment(String? value) {
    if (value != null) {
      //print(value + '33333333333333');
      userComment = value;
    }
  }

  Future<void> updateComment() async {
    tempString = '';
    FormState? currentState = state.formKey.currentState;
    //print('-------');
    //print(userComment);
    //startCircularProgress(state.context);
    if (currentState == null || !currentState.validate()) {
      return;
    }
    currentState.save();
    try {
      Map<String, dynamic> update = {};
      tempString = userComment! + ' - ' + userName!;
      tempMemo.comment.add(tempString);
      if (!listEquals(
          tempMemo.comment, state.widget.photoMemoList[index].comment)) {
        update[DockeyPhotoMemo.comment.name] = tempMemo.comment;
      }

      if (update.isNotEmpty) {
        tempMemo.timestamp = DateTime.now();
        print('-------');
        //print(userComment);
        update[DockeyPhotoMemo.timestamp.name] = tempMemo.timestamp;
        await FirestoreController.updatePhotoMemo(
            docId: tempMemo.docId!, update: update);

        state.widget.photoMemoList[index].copyFrom(tempMemo);
      }

      Navigator.of(state.context).pop();

      //print('=============== docId: $docId');
      //stopCircularProgress(state.context);
    } catch (e) {
      if (Constant.devMode) print('===== failed to update: $e');
      //showSnackBar(context: state.context, message: 'Failed to get update');
    }
  }
}
