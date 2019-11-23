import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage storage = FirebaseStorage();

class UploaderService {
  Future<StorageUploadTask> uploadFile(
      File file, StorageReference reference) async {
    final StorageUploadTask uploadTask = reference.putFile(
      file,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );

    return uploadTask;
  }

  Future<String> getDownloadUrl(StorageReference ref) async {
    final String url = await ref.getDownloadURL();
    return url;
  }
}
