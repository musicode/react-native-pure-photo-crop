# react-native-pure-photo-crop

This is a module which help you crop an image.

## Installation

```
npm i react-native-pure-photo-crop
// link below 0.60
react-native link react-native-pure-photo-crop
```

## Setup

### iOS

Modify `AppDelegate.m`

```
#import <RNTPhotoCropModule.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  [RNTPhotoCropModule setImageLoader:^(NSString *url, void (^ onComplete)(UIImage *)) {
    // add your image loader here
  }];

  return YES;
}
```

### Android

Add `jitpack` in your `android/build.gradle` at the end of repositories:

```
allprojects {
  repositories {
    ...
    maven { url 'https://jitpack.io' }
  }
}
```

Modify `MainApplication.java`

```java

import com.github.musicode.photocrop.RNTPhotoCropModule;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.functions.Function3;

public class MainApplication extends Application implements ReactApplication {

  @Override
  public void onCreate() {
    super.onCreate();

    RNTPhotoCropModule.setImageLoader(
      new Function3<Context, String, Function1, Unit>() {
        @Override
        public Unit invoke(Context context, String url, Function1 onComplete) {

          // add your image loader here

          return null;
        }
      }
    );
  }

}
```

## Usage

```js
import PhotoCrop from 'react-native-pure-photo-crop'

PhotoCrop.open({
  url: 'image url or file path',
  width: 300,
  height: 200,
  // optional
  cancelButtonTitle: '取消',
  // optional
  resetButtonTitle: '重置',
  // optional
  submitButtonTitle: '确定'
})
.then(file => {
  let { path, size, width, height } = file

})
.catch(error => {
  let { code } = error
  // -1: click cancel button
  // 1: has no permissions
  // 2: denied the requested permissions
  // 3: external storage is not writable
})

// compress an image without ui
PhotoCrop.compress({
  // image orignal info
  path: '/User/xx/xx.jpg',
  size: 10000,
  width: 1000,
  height: 600,

  // compress limit info you can accepted
  maxSize: 100 * 1024,
  maxWidth: 3000,
  maxHeight: 3000,

  // compress quality, 0 - 1
  quality: 0.5
})
.then(file => {
  let { path, size, width, height } = file

})
.catch(error => {
  let { code } = error

})
```