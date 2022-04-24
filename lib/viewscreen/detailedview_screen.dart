import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:termproject/controller/cloudstorage_controller.dart';
import 'package:termproject/controller/firestore_controller.dart';
import 'package:termproject/controller/ml_controller.dart';
import 'package:termproject/model/constant.dart';
import 'package:termproject/viewscreen/view/view_util.dart';
import 'package:termproject/viewscreen/view/webimage.dart';

import '../model/friend.dart';
import '../model/photo_memo.dart';
import 'view/webimage.dart';

class DetailedViewScreen extends StatefulWidget {
  static const routeName = '/detailedViewScreen';

  final User user;
  final PhotoMemo photoMemo;
  const DetailedViewScreen(
      {required this.user, required this.photoMemo, Key? key})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DetailedViewState();
  }
}

class _DetailedViewState extends State<DetailedViewScreen> {
  late _Controller con;
  bool editMode = false;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    //con.tempMemo.sharedWith = [];
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed View'),
        actions: [
          editMode
              ? IconButton(onPressed: con.update, icon: const Icon(Icons.check))
              : IconButton(onPressed: con.edit, icon: const Icon(Icons.edit))
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: con.photo == null
                          ? WebImage(
                              url: con.tempMemo.photoURL, context: context)
                          : Image.file(con.photo!),
                    ),
                    editMode
                        ? Positioned(
                            right: 0.0,
                            bottom: 0.0,
                            child: Container(
                              color: Colors.blue[200],
                              child: PopupMenuButton(
                                itemBuilder: (context) => [
                                  for (var source in PhotoSource.values)
                                    PopupMenuItem(
                                      child: Text(source.name),
                                      value: source,
                                    ),
                                ],
                                onSelected: con.getPhoto,
                              ),
                            ),
                          )
                        : const SizedBox(
                            height: 1.0,
                          ),
                  ],
                ),
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.headline6,
                decoration: const InputDecoration(hintText: 'Enter Title'),
                initialValue: con.tempMemo.title,
                validator: PhotoMemo.validateTitle,
                onSaved: con.saveTitle,
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.headline6,
                decoration: const InputDecoration(hintText: 'Enter Memo'),
                initialValue: con.tempMemo.memo,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                validator: PhotoMemo.validateMemo,
                onSaved: con.saveMemo,
              ),
              TextFormField(
                enabled: false,
                enableInteractiveSelection: false,
                style: Theme.of(context).textTheme.headline6,
                decoration: const InputDecoration(hintText: 'Comment Section'),
                initialValue: con.tempMemo.comment.join('\n'),
                maxLines: 15,
                keyboardType: TextInputType.emailAddress,
                validator: PhotoMemo.validateSharedWith,
                onSaved: con.saveSharedWith,
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.headline6,
                decoration: const InputDecoration(
                    hintText: 'Enter Shared With: email list'),
                initialValue: con.tempMemo.sharedWith.join('\n'),
                maxLines: 2,
                keyboardType: TextInputType.emailAddress,
                validator: PhotoMemo.validateSharedWith,
                onSaved: con.saveSharedWith,
              ),
              // Constant.devMode
              //     ? Text('Image Labels by ML \n${con.tempMemo.imageLabels}')
              //     : const SizedBox(
              //         height: 1.0,
              //       ),
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
      ),
    );
  }
}

class _Controller {
  _DetailedViewState state;
  late PhotoMemo tempMemo;
  List<int> selected = [];
  //late List<PhotoMemo> photoMemoList;
  late String? userComment = '';
  late String? userName = state.widget.user.email;
  late String? tempString = '';
  File? photo;
  _Controller(this.state) {
    print(
        '================= Testing error:  ${state.widget.photoMemo.sharedWith}');
    tempMemo = PhotoMemo.clone(state.widget.photoMemo);
  }

  Future<void> update() async {
    FormState? currentState = state.formKey.currentState;
    String? progressMessage;
    if (currentState == null) return;
    if (!currentState.validate()) return;
    currentState.save();

    print('== ${tempMemo}');

    startCircularProgress(state.context);

    try {
      Map<String, dynamic> update = {};
      if (photo != null) {
        Map result = await CloudStorageController.uploadPhotoFile(
          photo: photo!,
          filename: tempMemo.photoFilename,
          uid: state.widget.user.uid,
          listener: (int progress) {
            state.render(
              () {
                progressMessage =
                    progress == 100 ? null : 'UploadingL: $progress %';
              },
            );
          },
        );
        tempMemo.photoURL = result[ArgKey.downloadURL];
        update[DockeyPhotoMemo.photoURL.name] = tempMemo.photoURL;
        tempMemo.imageLabels =
            await GoogleMlController.getImageLabels(photo: photo!);
        update[DockeyPhotoMemo.imageLabel.name] = tempMemo.imageLabels;
      }

      if (tempMemo.title != state.widget.photoMemo.title) {
        update[DockeyPhotoMemo.title.name] = tempMemo.title;
      }

      if (tempMemo.memo != state.widget.photoMemo.memo) {
        update[DockeyPhotoMemo.memo.name] = tempMemo.memo;
      }
      if (!listEquals(tempMemo.sharedWith, state.widget.photoMemo.sharedWith)) {
        update[DockeyPhotoMemo.sharedWith.name] = tempMemo.sharedWith;
      }

      if (update.isNotEmpty) {
        tempMemo.timestamp = DateTime.now();
        update[DockeyPhotoMemo.timestamp.name] = tempMemo.timestamp;
        await FirestoreController.updatePhotoMemo(
            docId: tempMemo.docId!, update: update);

        state.widget.photoMemo.copyFrom(tempMemo);
      }

      stopCircularProgress(state.context);
      state.render(() => state.editMode = false);
    } catch (e) {
      stopCircularProgress(state.context);
      if (Constant.devMode) print('===== failed toupdate: $e');
      showSnackBar(context: state.context, message: 'Failed to get update');
    }
  }

  void edit() {
    state.render(() => state.editMode = true);
  }

  void saveTitle(String? value) {
    if (value != null) {
      tempMemo.title = value;
    }
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
    if (currentState == null) {
      return;
    }
    currentState.save();
    try {
      Map<String, dynamic> update = {};
      tempString = userComment! + ' - ' + userName!;
      tempMemo.comment.add(tempString);
      if (!listEquals(tempMemo.comment, state.widget.photoMemo.comment)) {
        update[DockeyPhotoMemo.comment.name] = tempMemo.comment;
      }

      if (update.isNotEmpty) {
        tempMemo.timestamp = DateTime.now();
        print('-------');
        //print(userComment);
        update[DockeyPhotoMemo.timestamp.name] = tempMemo.timestamp;
        await FirestoreController.updatePhotoMemo(
            docId: tempMemo.docId!, update: update);

        state.widget.photoMemo.copyFrom(tempMemo);
      }

      Navigator.of(state.context).pop();

      //print('=============== docId: $docId');
      //stopCircularProgress(state.context);
    } catch (e) {
      if (Constant.devMode) print('===== failed to update: $e');
      //showSnackBar(context: state.context, message: 'Failed to get update');
    }
  }

  void saveMemo(String? value) {
    //print('11111111111111111111111111111111111');
    if (value != null) {
      tempMemo.memo = value;
    }
  }

  void saveSharedWith(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      var emailList =
          value.trim().split(RegExp('(,|;| )+')).map((e) => e.trim()).toList();
      tempMemo.sharedWith = emailList;
    } else {
      tempMemo.sharedWith = [];
    }
  }

  Future<void> getPhoto(PhotoSource source) async {
    try {
      var imageSource = source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery;
      XFile? image = await ImagePicker().pickImage(source: imageSource);
      if (image == null) {
        return;
      }
      state.render(() => photo = File(image.path));
    } catch (e) {
      if (Constant.devMode) print('===== failed to get pic: $e');
      showSnackBar(context: state.context, message: 'Failed to get pick');
    }
  }
}
