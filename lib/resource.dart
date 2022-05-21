library cache_image;

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Resource {
  final String uri;
  final Duration duration;
  final double durationMultiplier;
  final Duration durationExpiration;

  Uri _temp;
  Uri _local;
  Uri _remote;
  Duration _retry;

  Resource(
      this.uri, this.duration, this.durationMultiplier, this.durationExpiration)
      : assert(uri != null),
        _retry = duration;

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
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child(_remote.path);
      final dynamic url = await ref.getDownloadURL();
      _remote = Uri.parse(url);
    }
    // Download file with retry
    while (file.lengthSync() <= 0) {
      await Future.delayed(_retry).then((_) async {
        try {
          HttpClient httpClient = new HttpClient();
          final HttpClientRequest request = await httpClient.getUrl(_remote);
          final HttpClientResponse response = await request.close();
          final Uint8List bytes = await consolidateHttpClientResponseBytes(
              response,
              autoUncompress: false);
          file = await file.writeAsBytes(bytes);
        } catch (err) {
          _retry += _retry * this.durationMultiplier;
        }
      });
      // Check duration expiration
      if (_retry > this.durationExpiration) {
        break;
      }
    }
    return file.readAsBytesSync();
  }
}
