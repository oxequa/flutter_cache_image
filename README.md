
# Flutter Cache Image

[![pub package](https://img.shields.io/pub/v/cache_image.svg)](https://pub.dartlang.org/packages/cache_image)

A Flutter plugin to load and cache network or firebase storage images with a retry mechanism if the download fails.
 
This package supports the download of images from a standard *network path* and from a *firebase storage gs path*. 

Images are stored in the temporary directory of the app.

## Usage

To use this plugin, add firebase_storage as a dependency in your pubspec.yaml file.

```
dependencies:
  cache_image: "^1.0.4"

```

Import cache_image in a dart file:
```
import 'package:cache_image/cache_image.dart';
```

To support firebase storage download the generated google-services.json file and place it inside android/app. Next, modify the android/build.gradle file and the android/app/build.gradle file to add the Google services plugin as described by the Firebase assistant. 

## How to use

Cache Image can be used with any widget that support an ImageProvider.

``` dart
Image(
    fit: BoxFit.cover,
    image: CacheImage('gs://your-project.appspot.com/image.png'),
),
Image(
    fit: BoxFit.cover,
    image:  CacheImage('https://hd.tudocdn.net/874944?w=646&h=284', duration: Duration(seconds: 2), durationExpiration: Duration(seconds: 10)),
),
FadeInImage(
    fit: BoxFit.cover,
    placeholder: AssetImage('assets/placeholder.png'),
    image: CacheImage('gs://your-project.appspot.com/image.jpg')
)
 ```

See the `example` directory for a complete sample app using Cache Image.