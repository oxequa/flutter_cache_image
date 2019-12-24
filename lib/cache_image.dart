library cache_image;

import 'dart:typed_data';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cache_image/resource.dart';

/*
 *  ImageCache for Flutter
 *
 *  Copyright (c) 2019 Oxequa - Alessio Pracchia
 *  Keep in touch https://www.linkedin.com/in/alessio-pracchia/
 *
 *  Released under MIT License.
 */

class CacheImage extends ImageProvider<CacheImage> {
  CacheImage(
    String url, {
    this.scale = 1.0,
    this.cache = true,
    this.retry = const Duration(milliseconds: 500),
  })  : assert(url != null),
        _resource = Resource(url);

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// Enable or disable image caching.
  final bool cache;

  /// Retry duration if download fails. Retry duration can be only set for the network image.
  final Duration retry;

  Resource _resource;

  Future<Codec> _fetchImage() async {
    await _resource.init();
    final bool check = await _resource.checkFile();
    if (check) {
      final Uint8List file = await _resource.getFile();
      return PaintingBinding.instance.instantiateImageCodec(file);
    }
    final Uint8List file = await _resource.storeFile();
    return PaintingBinding.instance.instantiateImageCodec(file);
  }

  @override
  Future<CacheImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CacheImage>(this);
  }

  @override
  ImageStreamCompleter load(CacheImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
        codec: key._fetchImage(),
        scale: key.scale,
        informationCollector: () sync* {
          yield DiagnosticsProperty<ImageProvider>(
              'Image provider: $this \n Image key: $key', this,
              style: DiagnosticsTreeStyle.errorProperty);
        });
  }
}
