
# Flutter Cache Image

A flutter library to cache network images. This package support the download of images from a standard *network url* and from a *firebase gs* storage url. 

This package depends only on the flutter firebase storage library; there are no others external dependencies. 

Images are stored in the app temporary directory.

## How to add

Add to pubspec.yaml:

```
dependencies:
  cache_image: "^0.0.1"

```
Add it to your dart file:
```
import 'package:cache_image/cache_image.dart';
```

## How to use

CacheImage widget can be used in two different way: 

###### Standard network image path

``` dart
return CacheImage.network(
  path: 'image_url_path',
  placeholder: new Container(
    padding: EdgeInsets.all(16.0),
    color: Colors.grey[100],
    child: new Center(
      child: new Image.asset('image_asset_path'),
    ),
  )
)
 ```
 
###### Firebase network image path

``` dart
return CacheImage.firebase(
  path: 'gs_url_path',
  placeholder: new Container(
    padding: EdgeInsets.all(16.0),
    color: Colors.grey[100],
    child: new Center(
      child: new Image.asset('image_asset_path'),
    ),
  )
)
 ```
 
## API

- Widget Placeholder - Widget to display when online image isn't in cache
- String Prefix - String used to parse gs firebase storage path.
- Duration Duration - Animation duration between placeholder and image.
- String Path - Firebase/Network image path.
