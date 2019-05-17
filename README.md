# RN59RootTag

ReactNative issue when send the app to background and return from. Create multiple instances of my app.

With RN Debugger is easy to see multiple rootTags when send app to BG (press device home button) and launch app again (Press app icon, shortcut or from app list). May someone say the debugger isnt real escenario, i take the time to create and test in release mode.

This issue is present in RN from versions under 0.54.x to latest versions

- [Multiple ReactInstanceManager.attachRootViewToInstace()...](https://github.com/facebook/react-native/issues/18081)
- [React-native creates multiple rootView on Android](https://stackoverflow.com/questions/48987915/react-native-creates-multiple-rootview-on-android)
- [rootTag changed when back button pressed #13679](https://github.com/facebook/react-native/issues/13679)

Scenario:

1. Checkout the project [RN59RootTag](https://github.com/castocolina/RN59RootTag)
2. Install dependencies `npm i`
3. Connect your device via USB and active debugging.
4. Install the app `react-native run-android --variant=release`
5. Open console and run logcat:

   ```
   export ANDROID_LOG_TAGS="*ActivityManager:V com.rn59roottag:V ReactNative:V ReactNativeBleManager:V ReactNativeJS:V *:S";
   adb logcat -T "$(date +'%m-%d %H:%M:%S.000')"
   ```

   Sample output at [output.txt](output.txt)

   > ... <br/>
   > 05-17 10:08:36.529 7812 7847 I ReactNativeJS: 89, 'RN59RootTag', 'componentDidMount'br</>
   > 05-17 10:08:59.201 7812 7847 I ReactNativeJS: 89, 'RN59RootTag', 'active', 'background'<br/>
   > 05-17 10:09:11.870 7812 7812 D ReactNative: ReactInstanceManager.attachRootViewToInstance()<br/>
   > 05-17 10:09:11.872 7812 7847 I ReactNativeJS: Running application "RN59RootTag" with appParams: {"rootTag":11}. **DEV** === false, development-level warning are OFF, performance optimizations are ON<br/>
   > 05-17 10:09:11.916 7812 7847 I ReactNativeJS: 85, 'RN59RootTag', 'componentDidMount'<br/>
   > 05-17 10:09:11.919 7812 7847 I ReactNativeJS: 89, 'RN59RootTag', 'background', 'active'<br/>
   > 05-17 10:09:11.921 7812 7847 I ReactNativeJS: 89, 'RN59RootTag', 'App has come to the foreground!'<br/>
   > 05-17 10:09:11.928 7812 7847 I ReactNativeJS: 85, 'RN59RootTag', 'background', 'active'<br/>
   > 05-17 10:09:11.928 7812 7847 I ReactNativeJS: 85, 'RN59RootTag', 'App has come to the foreground!'<br/>
   > 05-17 10:09:14.257 7812 7847 I ReactNativeJS: 89, 'RN59RootTag', 'active', 'background'<br/>
   > 05-17 10:09:14.273 7812 7847 I ReactNativeJS: 85, 'RN59RootTag', 'active', 'background'<br/>
   > ... <br/>

6. Launch app and press home button, launch app again and repeat many times.
7. What the logcat output. Many componentDidMount appInstances (see diferents instances numbers)
8. Press back button many times than app launches. Watch the card efect closing rendered layouts. Keep pressing to reach all and close app.
9. Now launch the app again many times and watch how the instance is unique from here.

For me this is problem bacasuse having many clients that install the app at first time could lauch many instances and create repeat event listener for externals apps causing duplicate request, create dirty data.

For me using my code the issue isnt fixed changing _android:launchMode="singleTop"_. The android app is unique, the rendered layout by RN isnt.

---

### Create the project

    npm i -g react-native;
    react-native init RN59RootTag;
    cd RN59RootTag;
    npm i;
    npm audit;
    npm audit fix -f;

### Run

    adb devices;
    # Debug mode
    react-native run-android;
    # Release mode
    react-native run-android --variant=release;

### Debug

    export ANDROID_LOG_TAGS="*ActivityManager:V com.rn59roottag:V ReactNative:V ReactNativeBleManager:V ReactNativeJS:V *:S";
    # To see log history in device
    adb logcat;
    # To see only current and future logs
    adb logcat -T "$(date +'%m-%d %H:%M:%S.000')";

#### My environment

- OS:

  `sw_vers`

  > ProductName: Mac OS X<br/>
  > ProductVersion: 10.13.6<br/>
  > BuildVersion: 17G5019

- ADB:

  `adb version`

  > Android Debug Bridge version 1.0.40<br/>
  > Version 4986621<br/>
  > Installed as /usr/local/bin/adb

- react-native

  `react-native -v`

  > react-native-cli: 2.0.1 <br/>
  > react-native: n/a - not inside a React Native project directory

- Device:

  ```
    adb shell getprop | egrep \
    'product.manufacturer|product.brand|product.model|ro.build.version.release|ro.build.version.sdk'
  ```

> > ```
> > [ro.build.version.release]: [9]
> > [ro.build.version.sdk]: [28]
> > [ro.product.brand]: [Xiaomi]
> > [ro.product.manufacturer]: [Xiaomi]
> > [ro.product.model]: [Mi MIX 2S]
> > ```

---

> > ```
> > [ro.build.version.release]: [7.1.2]
> > [ro.build.version.sdk]: [25]
> > [ro.product.brand]: [Zebra]
> > [ro.product.manufacturer]: [Zebra Technologies]
> > [ro.product.model]: [TC70x]
> > ```
