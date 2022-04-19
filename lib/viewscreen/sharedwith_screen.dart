//import 'dart:js';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:termproject/viewscreen/view/view_util.dart';
import 'package:termproject/viewscreen/view/webimage.dart';

import '../model/constant.dart';
import '../model/photo_memo.dart';

class SharedWithScreen extends StatelessWidget {
  static const routeName = '/sharedWithScreen';

  final List<PhotoMemo> photoMemoList;
  final User user;
  late _Controller con = _Controller(this);
  var formKey = GlobalKey<FormState>();

  SharedWithScreen({
    required this.user,
    required this.photoMemoList,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Shared With : ${user.email}'),
      ),
      body: SingleChildScrollView(
        child: photoMemoList.isEmpty
            ? const Text('No PhotoMemo shared')
            : Column(
                children: [
                  for (var photoMemo in photoMemoList)
                    Card(
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
                                url: photoMemo.photoURL,
                                context: context,
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                              ),
                            ),
                            Text(
                              photoMemo.title,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            Text(photoMemo.memo),
                            Text('Created By: ${photoMemo.createBy}'),
                            Text('Created at: ${photoMemo.timestamp}'),
                            Text(' Shared With: ${photoMemo.sharedWith}'),
                            /*Constant.devMode
                                ? Text('Image Labels: ${photoMemo.imageLabels}')
                                : const SizedBox(height: 1.0),*/
                            TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Add comment?',
                                  fillColor: Color.fromARGB(255, 206, 201, 201),
                                  filled: true,
                                ),
                                autocorrect: true,
                                onSaved: con.saveSearchKey),
                            ElevatedButton(
                              onPressed: con.updateComment,
                              child: Text(
                                'Upload Comment?',
                                style: Theme.of(context).textTheme.button,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
      ),
    );
  }
}

class _Controller {
  late SharedWithScreen state;
  late List<PhotoMemo> photoMemoList;
  late String? userComment;
  late PhotoMemo tempMemo;

  _Controller(this.state) {
    photoMemoList = state.photoMemoList;
    //tempMemo = PhotoMemo.clone(state.widget.photoMemo);
  }

  void saveSearchKey(String? value) {
    userComment = value;
  }

  void updateComment() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) {
      return;
    }
    try {} catch (e) {
      if (Constant.devMode) print('===== failed to update: $e');
      //showSnackBar(context: state.context, message: 'Failed to get update');
    }
  }
}
