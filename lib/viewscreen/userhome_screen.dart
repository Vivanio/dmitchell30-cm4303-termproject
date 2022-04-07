import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:termproject/controller/auth_controller.dart';
import 'package:termproject/controller/firestore_controller.dart';
import 'package:termproject/model/constant.dart';
import 'package:termproject/model/photo_memo.dart';
import 'package:termproject/viewscreen/addphotomemo_screen.dart';
import 'package:termproject/viewscreen/sharedwith_screen.dart';
import 'package:termproject/viewscreen/view/view_util.dart';
import 'package:termproject/viewscreen/view/webimage.dart';

import '../controller/cloudstorage_controller.dart';
import 'detailedview_screen.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/userhomeScreen';

  const UserHomeScreen(
      {required this.user, required this.photoMemoList, Key? key})
      : super(key: key);

  final User user;
  final List<PhotoMemo> photoMemoList;

  @override
  State<StatefulWidget> createState() {
    return _UserHomeState();
  }
}

class _UserHomeState extends State<UserHomeScreen> {
  late _Controller con;
  late String email;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    email = widget.user.email ?? 'No email';
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          //title: const Text('User Home'),
          actions: [
            con.selected.isEmpty
                ? Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Search (empty for all)',
                            fillColor: Color.fromARGB(255, 83, 54, 54),
                            filled: true,
                          ),
                          autocorrect: true,
                          onSaved: con.saveSearchKey,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: con.cancel,
                  ),
            con.selected.isEmpty
                ? IconButton(onPressed: con.search, icon: Icon(Icons.search))
                : IconButton(
                    onPressed: con.delete, icon: const Icon(Icons.delete)),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: const Icon(
                  Icons.person,
                  size: 70.0,
                ),
                accountName: const Text('No Profile'),
                accountEmail: Text(email),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: con.signOut,
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Shared With'),
                onTap: con.sharedWith,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: con.addButton,
        ),
        body: con.photoMemoList.isEmpty
            ? Text(
                'No PhotoMemo Found',
                style: Theme.of(context).textTheme.headline6,
              )
            : ListView.builder(
                itemCount: con.photoMemoList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    selected: con.selected.contains(index),
                    selectedTileColor: Colors.blue[100],
                    tileColor: Colors.grey,
                    leading: WebImage(
                      url: con.photoMemoList[index].photoURL,
                      context: context,
                    ),
                    trailing: const Icon(Icons.arrow_right),
                    title: Text(con.photoMemoList[index].title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          con.photoMemoList[index].memo.length >= 40
                              ? con.photoMemoList[index].memo.substring(0, 40) +
                                  '...'
                              : con.photoMemoList[index].memo,
                        ),
                        Text(
                            'Created by: ${con.photoMemoList[index].createBy}'),
                        Text(
                            'Shared with : ${con.photoMemoList[index].sharedWith}'),
                        Text(
                            'Timestamp: ${con.photoMemoList[index].timestamp}'),
                      ],
                    ),
                    onTap: () => con.onTap(index),
                    onLongPress: () => con.onLongPress(index),
                  );
                },
              ),
        //Text('${widget.photoMemoList.length}'),
      ),
    );
  }
}

class _Controller {
  _UserHomeState state;
  late List<PhotoMemo> photoMemoList;
  List<int> selected = [];
  String? searchKeyString;

  _Controller(this.state) {
    photoMemoList = state.widget.photoMemoList;
  }

  void cancel() {
    state.render(() => selected.clear());
  }

  Future<void> delete() async {
    startCircularProgress(state.context);
    selected.sort();
    for (int i = selected.length - 1; i >= 0; i--) {
      try {
        PhotoMemo p = photoMemoList[selected[i]];
        await FirestoreController.deleteDoc(docId: p.docId!);
        await CloudStorageController.deleteFile(filename: p.photoFilename);
        state.render(() {
          photoMemoList.removeAt(selected[i]);
        });
      } catch (e) {
        if (Constant.devMode) print('Failed to delete: $e');
        showSnackBar(
            context: state.context,
            seconds: 20,
            message: 'Failed! Sign out and try again');
        break;
      }
    }
    stopCircularProgress(state.context);

    // state.render(() => selected.clear());
  }

  Future<void> sharedWith() async {
    try {
      print("fff");
      List<PhotoMemo> photoMemoList =
          await FirestoreController.getPhotoMemoListSharedWithMe(
              email: state.email);
      Navigator.pushNamed(
        state.context,
        SharedWithScreen.routeName,
        arguments: {
          ArgKey.photoMemoList: photoMemoList,
          ArgKey.user: state.widget.user,
        },
      );
      print("dddd");
      Navigator.of(state.context).pop();
    } catch (e) {
      if (Constant.devMode) print('get SharedWih list fail: $e');
      showSnackBar(
          context: state.context,
          seconds: 20,
          message: 'Get shared with list fail $e');
      //break;
    }
  }

  void search() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    currentState.save();

    List<String> keys = [];
    if (searchKeyString != null) {
      var tokens = searchKeyString!.split(RegExp('(,| )+')).toList();
      for (var t in tokens) {
        if (t.trim().isNotEmpty) keys.add(t.trim().toLowerCase());
      }
    }
    startCircularProgress(state.context);
    try {
      late List<PhotoMemo> results;
      if (keys.isEmpty) {
        results =
            await FirestoreController.getPhotoMemoList(email: state.email);
      } else {
        results = await FirestoreController.searchImages(
          email: state.email,
          searchLabel: keys,
        );
      }
      stopCircularProgress(state.context);
      state.render(() {
        photoMemoList = results;
      });
    } catch (e) {
      stopCircularProgress(state.context);
      if (Constant.devMode) {
        print('======== failed to search: $e');
      }
      showSnackBar(
          context: state.context, seconds: 20, message: 'failed to search: $e');
    }
  }

  void saveSearchKey(String? value) {
    searchKeyString = value;
  }

  void addButton() async {
    await Navigator.pushNamed(
      state.context,
      AddPhotoMemoScreen.routeName,
      arguments: {
        ArgKey.user: state.widget.user,
        ArgKey.photoMemoList: photoMemoList,
      },
    );
    state.render(() {});
  }

  Future<void> signOut() async {
    try {
      await AuthController.signout();
    } catch (e) {
      if (Constant.devMode) print('========= Sign Out Error :$e');
      showSnackBar(context: state.context, message: 'Sign Out Error :$e');
    }

    Navigator.of(state.context).pop();
    Navigator.of(state.context).pop();
  }

  void onTap(int index) {
    Navigator.pushNamed(
      state.context,
      DetailedViewScreen.routeName,
      arguments: {
        ArgKey.user: state.widget.user,
        ArgKey.onePhotoMemo: photoMemoList[index],
      },
    );
    state.render(() {});
  }

  void onLongPress(int index) {
    if (selected.contains(index)) {
      selected.remove(index);
    } else {
      selected.add(index);
    }
  }
}
