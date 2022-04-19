enum PhotoSource { camera, gallery }

enum DockeyPhotoMemo {
  createBy,
  title,
  memo,
  photoFilename,
  photoURL,
  timestamp,
  imageLabel,
  sharedWith,
  comment
}

class PhotoMemo {
  String? docId; //Firestore auto-generated id
  late String createBy; // email = userid
  late String title;
  late String memo;
  late String photoFilename; // image/photo file at Cloud Storage
  late String photoURL; //URL of image
  DateTime? timestamp;
  late List<dynamic> imageLabels; //ML generated image label
  late List<dynamic> sharedWith; //list of emails
  late List<dynamic> comment;

  PhotoMemo({
    this.docId,
    this.createBy = '',
    this.title = '',
    this.memo = '',
    this.photoFilename = '',
    this.photoURL = '',
    this.timestamp,
    List<dynamic>? imageLabels,
    List<dynamic>? sharedWith,
    List<dynamic>? comment,
  }) {
    this.imageLabels = imageLabels == null ? [] : [...imageLabels];
    this.sharedWith = sharedWith == null ? [] : [...sharedWith];
    this.comment = comment == null ? [] : [...comment];
  }

  PhotoMemo.clone(PhotoMemo p) {
    docId = p.docId;
    createBy = p.createBy;
    title = p.title;
    memo = p.memo;
    photoFilename = p.photoFilename;
    photoURL = p.photoURL;
    timestamp = p.timestamp;
    //sharedWith.clear();
    //sharedWith.addAll(p.sharedWith);
    //imageLabels.clear();
    //imageLabels.addAll(p.imageLabels);
    sharedWith = [...p.sharedWith];
    imageLabels = [...p.imageLabels];
    comment = [...p.comment];
  }

  void copyFrom(PhotoMemo p) {
    docId = p.docId;
    createBy = p.createBy;
    title = p.title;
    memo = p.memo;
    photoFilename = p.photoFilename;
    photoURL = p.photoURL;
    timestamp = p.timestamp;
    sharedWith.clear();
    sharedWith.addAll(p.sharedWith);
    imageLabels.clear();
    imageLabels.addAll(p.imageLabels);
    comment.clear();
    comment.addAll(p.comment);
  }

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DockeyPhotoMemo.title.name: title,
      DockeyPhotoMemo.createBy.name: createBy,
      DockeyPhotoMemo.memo.name: memo,
      DockeyPhotoMemo.photoFilename.name: photoFilename,
      DockeyPhotoMemo.photoURL.name: photoURL,
      DockeyPhotoMemo.sharedWith.name: sharedWith,
      DockeyPhotoMemo.imageLabel.name: imageLabels,
      DockeyPhotoMemo.timestamp.name: timestamp,
      DockeyPhotoMemo.comment.name: comment
    };
  }

  static PhotoMemo? fromFirestoreDoc({
    required Map<String, dynamic> doc,
    required String docId,
  }) {
    return PhotoMemo(
      docId: docId,
      createBy: doc[DockeyPhotoMemo.createBy.name] ??= 'N/A',
      title: doc[DockeyPhotoMemo.title.name] ??= 'N/A',
      memo: doc[DockeyPhotoMemo.memo.name] ??= 'N/A',
      photoFilename: doc[DockeyPhotoMemo.photoFilename.name] ??= 'N/A',
      photoURL: doc[DockeyPhotoMemo.photoURL.name] ??= 'N/A',
      sharedWith: doc[DockeyPhotoMemo.sharedWith.name] ??= [],
      imageLabels: doc[DockeyPhotoMemo.imageLabel.name] ??= [],
      comment: doc[DockeyPhotoMemo.comment.name] ??= [],
      timestamp: doc[DockeyPhotoMemo.timestamp.name] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[DockeyPhotoMemo.timestamp.name].millisecondsSinceEpoch,
            )
          : DateTime.now(),
    );
  }

  static String? validateTitle(String? value) {
    return (value == null || value.trim().length < 3)
        ? 'Title too short'
        : null;
  }

  static String? validateMemo(String? value) {
    return (value == null || value.trim().length < 5) ? 'Memo too short' : null;
  }

  static String? validateSharedWith(String? value) {
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
