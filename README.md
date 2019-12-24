
# Flutter Cache Image

A flutter library to download and cache images. This package supports the download of images from a standard *network path* and from a *firebase storage path*. 

This package depends only on Flutter firebase storage and path provider; there are no other external dependencies. 

Images are stored ok the temporary directory of the app.

## How to add

Add to pubspec.yaml:

```
dependencies:
  cache_image: "^1.0.0"

```
Add it to a dart file:
```
import 'package:cache_image/cache_image.dart';
```

To support firebase storage download the generated google-services.json file and place it inside android/app. Next, modify the android/build.gradle file and the android/app/build.gradle file to add the Google services plugin as described by the Firebase assistant. 

## How to use

CacheImage can be used with any widget that requires an image as ImageProvider. Check example app for a live sample.

``` dart
Image(
    fit: BoxFit.cover,
    image: CacheImage('gs://your-project.appspot.com/image.png'),
),
Image(
    fit: BoxFit.cover,
    image: CacheImage('https://your-website.com/image.png'),
)
 ```