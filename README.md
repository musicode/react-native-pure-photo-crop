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
#import <RNTPhotoCrop.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  [RNTPhotoCrop init:^(NSString *url, void (^ onComplete)(UIImage *)) {
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

Modify `MainApplication`

```kotlin
class MainApplication : Application(), ReactApplication {

  override fun onCreate() {
    super.onCreate()

    RNTPhotoCropModule.init { context, url, onComplete ->

        // load image by url
        // onComplete.invoke(null): load error
        // onComplete.invoke(bitmap): load success

    }

  }

}
```

## Usage

```js
import photoCrop from 'react-native-pure-photo-crop'

// At first, make sure you have the permissions.
// ios: nothing
// android: WRITE_EXTERNAL_STORAGE

// If you don't have these permissions, you can't call open method.

photoCrop.open({
  url: 'image url or file path',
  width: 300,
  height: 200,
  // optional
  guideLabelTitle: '',
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
  // click cancel button
})
```