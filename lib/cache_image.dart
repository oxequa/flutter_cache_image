library cache_image;

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

/*
 *  ImageCache for Flutter
 *
 *  Copyright (c) 2018 Oxequa - Alessio Pracchia
 *
 *  Released under MIT License.
 */

class CacheImage extends StatefulWidget {

  CacheImage.firebase({
    Key key,
    this.placeholder,
    this.prefix = 'appspot.com',
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.duration = const Duration(milliseconds: 500),
    this.durationLocal = const Duration(milliseconds: 0),
    @required this.path,
  }) : type = 1,
       assert(path != null),
       super(key: key);

  CacheImage.network({
    Key key,
    this.placeholder,
    this.prefix,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.duration = const Duration(milliseconds: 500),
    this.durationLocal = const Duration(milliseconds: 0),
    @required this.path,
  }) : type = 2,
       assert(path != null),
       super(key: key);

  /// Widget displayed while image is loading.
  final String path;

  /// Widget displayed while image is loading.
  final int type;

  /// Widget displayed while image is loading.
  final String prefix;

  /// Widget displayed while image is loading.
  final Widget placeholder;

  /// Widget displayed while image is loading from network.
  final Duration duration;

  /// Widget displayed while image is loading from local.
  final Duration durationLocal;

  /// If non-null, require the image to have this width.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  ///
  /// It is strongly recommended that either both the [width] and the [height]
  /// be specified, or that the widget be placed in a context that sets tight
  /// layout constraints, so that the image does not change size as it loads.
  /// Consider using [fit] to adapt the image's rendering to fit the given width
  /// and height if the exact image dimensions are not known in advance.
  final double width;

  /// If non-null, require the image to have this height.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  ///
  /// It is strongly recommended that either both the [width] and the [height]
  /// be specified, or that the widget be placed in a context that sets tight
  /// layout constraints, so that the image does not change size as it loads.
  /// Consider using [fit] to adapt the image's rendering to fit the given width
  /// and height if the exact image dimensions are not known in advance.
  final double height;

  /// If non-null, this color is blended with each image pixel using [colorBlendMode].
  final Color color;

  /// Used to combine [color] with this image.
  ///
  /// The default is [BlendMode.srcIn]. In terms of the blend mode, [color] is
  /// the source and this image is the destination.
  ///
  /// See also:
  ///
  ///  * [BlendMode], which includes an illustration of the effect of each blend mode.
  final BlendMode colorBlendMode;

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  final BoxFit fit;

  /// How to align the image within its bounds.
  ///
  /// The alignment aligns the given position in the image to the given position
  /// in the layout bounds. For example, an [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while an
  /// [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
  /// image with the bottom right corner of its layout bounds. Similarly, an
  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
  /// middle of the bottom edge of its layout bounds.
  ///
  /// To display a subpart of an image, consider using a [CustomPainter] and
  /// [Canvas.drawImageRect].
  ///
  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
  /// [AlignmentDirectional]), then an ambient [Directionality] widget
  /// must be in scope.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// How to paint any portions of the layout bounds not covered by the image.
  final ImageRepeat repeat;

  /// The center slice for a nine-patch image.
  ///
  /// The region of the image inside the center slice will be stretched both
  /// horizontally and vertically to fit the image into its destination. The
  /// region of the image above and below the center slice will be stretched
  /// only horizontally and the region of the image to the left and right of
  /// the center slice will be stretched only vertically.
  final Rect centerSlice;

  /// Whether to paint the image in the direction of the [TextDirection].
  ///
  /// If this is true, then in [TextDirection.ltr] contexts, the image will be
  /// drawn with its origin in the top left (the "normal" painting direction for
  /// images); and in [TextDirection.rtl] contexts, the image will be drawn with
  /// a scaling factor of -1 in the horizontal direction so that the origin is
  /// in the top right.
  ///
  /// This is occasionally used with images in right-to-left environments, for
  /// images that were designed for left-to-right locales. Be careful, when
  /// using this, to not flip images with integral shadows, text, or other
  /// effects that will look incorrect when flipped.
  ///
  /// If this is true, there must be an ambient [Directionality] widget in
  /// scope.
  final bool matchTextDirection;

  /// Whether to continue showing the old image (true), or briefly show nothing
  /// (false), when the image provider changes.
  final bool gaplessPlayback;


  @override
  State<StatefulWidget> createState() => new _CacheImage();
}

class _CacheImage extends State<CacheImage> {

  String filePath;
  Duration duration = Duration(milliseconds: 300);
  final Directory tempDir = Directory.systemTemp;

  Future<String> network(String path) async {
    HttpClient httpClient = new HttpClient();
    var request = await httpClient.getUrl(Uri.parse(path));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    var split = path.split('/');
    File file = new File(tempDir.path + split[split.length - 1]);
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<String> firebase(String path) async {
    var file = File(tempDir.path + path);
    var ref = FirebaseStorage.instance.ref().child(path);
    var download = ref.writeToFile(file);
    var bytes = (await download.future).totalByteCount;
    if(bytes.bitLength > 0) {
      return file.path;
    } else {
      return null;
    }
  }

  void parse() {
    String local;
    List<String> splitted;
    switch (widget.type){
      case 1:
        splitted = widget.path.split(widget.prefix);
        local = tempDir.path + splitted[splitted.length - 1];
        break;
      case 2:
        splitted = widget.path.split('/');
        local = tempDir.path + splitted[splitted.length - 1];
        break;
    }
    File(local).length().then((length){
      duration = widget.durationLocal;
      update(local);
    }).catchError((err){
      switch(widget.type){
        case 1:
          firebase(splitted[splitted.length - 1]).then((result){
            update(result);
          });
          break;
        case 2:
          network(widget.path).then((result){
            update(result);
          });
          break;
      }
    });
  }

  void update(String path) {
    if (this.mounted) {
      setState(() {
        filePath = path;
      });
    }
  }

  @override
  void didUpdateWidget(CacheImage oldWidget) {
    if(oldWidget.path != widget.path) {
      parse();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    duration = widget.duration;
    parse();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedCrossFade(
      firstChild: widget.placeholder != null
        ? widget.placeholder
        : Container(height: 0.0, width: 0.0),
      secondChild: filePath != null
        ? Image.asset(
          filePath,
          height: widget.height,
          width: widget.width,
          color: widget.color,
          colorBlendMode: widget.colorBlendMode,
          fit: widget.fit,
          alignment: widget.alignment,
          repeat: widget.repeat,
          centerSlice: widget.centerSlice,
          matchTextDirection: widget.matchTextDirection,
          gaplessPlayback: widget.gaplessPlayback)
        : new Container(height: 0.0, width: 0.0),
      crossFadeState: filePath == null
        ? CrossFadeState.showFirst
        : CrossFadeState.showSecond,
      duration: duration
    );
  }
}
