import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:termproject/model/constant.dart';
import 'package:uuid/uuid.dart';
//import 'package:uuid/uuid.dart';

class CloudStorageController {
  static Future<Map<ArgKey, String>> uploadPhotoFile({
    required File photo,
    String? filename,
    required String uid,
    required Function listener,
  }) async {
    filename ??= '${Constant.photoFileFolder}/$uid/${const Uuid().v1()}';
    //print('BOOOOM!');

    UploadTask task = FirebaseStorage.instance.ref(filename).putFile(photo);
    //print('BOOOOM!');

    task.snapshotEvents.listen((TaskSnapshot event) {
      int progress = (event.bytesTransferred / event.totalBytes * 100).toInt();
      listener(progress);
    });
    //print('BOOOOM!');

    TaskSnapshot snapshot = await task;
    //print('OOOOOOM!');
    String downloadURL = await snapshot.ref.getDownloadURL();
    //print('BOOOOM!');

    return {
      ArgKey.downloadURL: downloadURL,
      ArgKey.filename: filename,
    };
  }

  static Future<void> deleteFile({
    required String filename,
  }) async {
    await FirebaseStorage.instance.ref().child(filename).delete();
  }
}
