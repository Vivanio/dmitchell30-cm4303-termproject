//enum PhotoSource { camera, gallery }

enum DockeyFriend {
  user,
  friend,
}

class Friend {
  String? docId;
  late String user;
  late List<dynamic> friend;

  Friend({
    this.docId,
    this.user = '',
    List<dynamic>? friend,
  }) {
    this.friend = friend == null ? [] : [...friend];
  }

  Friend.close(Friend f) {
    docId = f.docId;
    user = f.user;
    friend = [...f.friend];
  }

  void copyFrom(Friend f) {
    docId = f.docId;
    user = f.user;
    friend.clear();
    friend.addAll(f.friend);
  }

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DockeyFriend.user.name: user,
      DockeyFriend.friend.name: friend,
    };
  }

  static Friend? fromFirestoreDoc({
    required Map<String, dynamic> doc,
    required String docId,
  }) {
    return Friend(
      docId: docId,
      user: doc[DockeyFriend.user.name] ??= 'N/A',
      friend: doc[DockeyFriend.friend.name] ??= [],
    );
  }

  static String? validateEmail(String? value) {
    if (value == null || !(value.contains('@') && value.contains('.'))) {
      return 'Invalid Email';
    } else {
      return null;
    }
  }

  static String? validateComment(String? value) {
    return (value == null || value.trim().length < 5) ? 'Memo too short' : null;
  }

  static String? validateFriendEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    List<String> emailList =
        value.trim().split(RegExp('(,|;| )+')).map((e) => e.trim()).toList();
    for (String e in emailList) {
      if (e.contains('@') && e.contains('.')) {
        continue;
      } else {
        return 'Invalid email address found: comma, semicolon, space separted list';
      }
    }
    //return null;
  }
}
