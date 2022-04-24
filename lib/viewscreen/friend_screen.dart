import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../controller/firestore_controller.dart';
import '../model/constant.dart';
import '../model/friend.dart';
import 'addfriend_screen.dart';

class FriendScreen extends StatefulWidget {
  static const routeName = '/friendScreen';

  const FriendScreen({required this.user, required this.friendList, Key? key})
      : super(key: key);
  final User user;
  final List<Friend> friendList;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FriendState();
  }
}

class _FriendState extends State<FriendScreen> {
  late _Controller con;
  late String email;
  var formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    con = _Controller(this);
    email = widget.user.email ?? 'no email';
    super.initState();
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend List'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: con.addFriend,
      ),
      body: Form(
        key: formKey,
        child: con.friendlist.isEmpty
            ? Text(
                'No Friends',
              )
            : ListView.builder(
                itemCount: con.friendlist.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    selected: con.selected.contains(index),
                    selectedTileColor: Colors.blue[100],
                    tileColor: Colors.grey,
                    title: Text(con.friendlist[index].user),
                  );
                },
              ),
      ),
    );
  }
}

class _Controller {
  _FriendState state;
  late List<Friend> friendlist;
  List<int> selected = [];

  _Controller(this.state) {
    friendlist = state.widget.friendList;
  }

  void addFriend() async {
    List<Friend> photoMemoList =
        await FirestoreController.getFriend(email: state.widget.user.email!);
    await Navigator.pushNamed(
      state.context,
      AddFriendScreen.routeName,
      arguments: {
        ArgKey.user: state.widget.user,
        ArgKey.friend: friendlist,
      },
    );
  }

  void cancel() {
    state.render(() => selected.clear());
  }

  Future<void> delete() async {}
}
