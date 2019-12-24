library cache_image;

import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class Resource {
  final String uri;

  Uri _temp;
  Uri _local;
  Uri _remote;
  Duration _duration = Duration(milliseconds: 0);

  Resource(this.uri) : assert(uri != null);

  Uri get remote => _remote;
  Uri get temp => _temp;
  Uri get local => _local;

  Uri _parse(String uri) {
    return Uri.parse(uri);
  }

  Future<Uri> _getTempDir() async {
    final Directory temp = await getTemporaryDirectory();
    return _parse(temp.path);
  }

  Future<Resource> init() async {
    _temp = await _getTempDir();
    _remote = _parse(uri);
    _local = _parse(_temp.path + _remote.path);
    return this;
  }

  Future<bool> checkFile() async {
    final File file = File(_local.path);
    if (file.existsSync() && file.lengthSync() > 0) {
      return true;
    }
    return false;
  }

  Future<Uint8List> getFile() async {
    final File file = File(_local.path);
    if (file.existsSync() && file.lengthSync() > 0) {
      return file.readAsBytesSync();
    }
    return null;
  }

  Future<Uint8List> storeFile() async {
    File file = await File(_local.path).create(recursive: true);
    // Check FireStorage scheme
    if (_remote.scheme == 'gs') {
      print(_remote.path);
      final StorageReference ref =
          FirebaseStorage.instance.ref().child(_remote.path);
      final dynamic url = await ref.getDownloadURL();
      _remote = Uri.parse(url);
    }
    // Download file with retry
    while (file.lengthSync() <= 0) {
      await Future.delayed(_duration).then((_) async {
        try {
          HttpClient httpClient = new HttpClient();
          final HttpClientRequest request = await httpClient.getUrl(_remote);
          final HttpClientResponse response = await request.close();
          final Uint8List bytes = await consolidateHttpClientResponseBytes(
              response,
              autoUncompress: false);
          file = await file.writeAsBytes(bytes);
        } catch (err) {
          _duration = Duration(milliseconds: 2500);
        }
      });
    }
    return file.readAsBytesSync();
  }
}
