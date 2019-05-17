# RN59RootTag

## Description

ReactNative issue when send the app to background and return from. Create multiple instances of my component.

With RN Debugger is easy to see multiple rootTags when send app to BG (press device home button) and launch app again (Press app icon, shortcut or from app list). May someone say the debugger isnt real escenario, i take the time to create and test in release mode.

This issue is present in RN from versions under 0.54.x to latest versions

- [Multiple ReactInstanceManager.attachRootViewToInstace()...](https://github.com/facebook/react-native/issues/18081)
- [React-native creates multiple rootView on Android](https://stackoverflow.com/questions/48987915/react-native-creates-multiple-rootview-on-android)
- [rootTag changed when back button pressed #13679](https://github.com/facebook/react-native/issues/13679)
- [Multiple app instances on first run #13029](https://github.com/facebook/react-native/issues/13029)

## [ENV] React Native version:

```
React Native Environment Info:
  System:
    OS: macOS High Sierra 10.13.6
    CPU: (8) x64 Intel(R) Core(TM) i5-8259U CPU @ 2.30GHz
    Memory: 87.59 MB / 8.00 GB
    Shell: 5.3 - /bin/zsh
  Binaries:
    Node: 10.15.1 - ~/.nvm/versions/node/v10.15.1/bin/node
    Yarn: 1.12.3 - /usr/local/bin/yarn
    npm: 6.9.0 - ~/.nvm/versions/node/v10.15.1/bin/npm
    Watchman: 4.9.0 - /usr/local/bin/watchman
  SDKs:
    iOS SDK:
      Platforms: iOS 12.1, macOS 10.14, tvOS 12.1, watchOS 5.1
    Android SDK:
      API Levels: 23, 24, 25, 26, 27, 28
      Build Tools: 24.0.1, 25.0.3, 26.0.2, 26.0.3, 27.0.3, 28.0.2, 28.0.3
      System Images: android-21 | Google APIs Intel x86 Atom, android-22 | Intel x86 Atom, android-23 | Intel x86 Atom, android-23 | Google APIs Intel x86 Atom, android-25 | Google Play Intel x86 Atom, android-27 | Google Play Intel x86 Atom, android-28 | Google APIs Intel x86 Atom
  IDEs:
    Android Studio: 3.2 AI-181.5540.7.32.5014246
    Xcode: 10.1/10B61 - /usr/bin/xcodebuild
  npmPackages:
    react: 16.8.3 => 16.8.3
    react-native: 0.59.8 => 0.59.8
  npmGlobalPackages:
    create-react-native-app: 2.0.2
    react-native-cli: 2.0.1
```

#### My Devices:

- Zebra TC70x
- Xiaomi MI Mix 2S

## Scenario (Steps to reproduce):

1. Checkout the project [RN59RootTag](https://github.com/castocolina/RN59RootTag)
2. Install dependencies `npm i`
3. Connect your device via USB and active debugging.
4. Install the app `react-native run-android --variant=release`
5. Open console and run logcat:

   ```
   export ANDROID_LOG_TAGS="*ActivityManager:V com.rn59roottag:V ReactNative:V ReactNativeBleManager:V ReactNativeJS:V *:S";
   adb logcat -T "$(date +'%m-%d %H:%M:%S.000')"
   ```

6. Launch app and press home button, launch app again and repeat many times.
7. What the logcat output. Many componentDidMount appInstances (see diferents instances numbers)
8. Press back button many times than app launches. Watch the card efect closing rendered layouts. Keep pressing to reach all and close app.
9. Now launch the app again many times and watch how the instance is unique from here.

#### What you expected to happen?

When return from background keep my component instance.

For me this is problem bacasuse having many clients that install the app at first time could lauch many instances and create repeat event listener for externals apps causing duplicate request, create dirty data.

## Snack, code example, or link to a repository

From sample RN init class with few modifications to print sample random id when activate/background

```
....
export default class App extends Component<Props> {
  state = {
    appState: AppState.currentState
  };

  constructor() {
    super();
    if (!this.compId) {
      this.compId = Math.floor(Math.random() * 100) + 1;
    }
    this.compName = cmpName;
  }

  componentDidMount() {
    const { compId, compName } = this;
    console.info(compId, compName, "componentDidMount");
    AppState.addEventListener("change", this._handleAppStateChange);
  }

  componentWillUnmount() {
    const { compId, compName } = this;
    console.info(compId, compName, "componentWillUnmount");
    AppState.removeEventListener("change", this._handleAppStateChange);
  }

  _handleAppStateChange = nextAppState => {
    const { compId, compName } = this;
    const { appState } = this.state;
    console.info(compId, compName, appState, nextAppState);

    if (appState.match(/inactive|background/) && nextAppState === "active") {
      console.log(compId, compName, "App has come to the foreground!");
    }
    this.setState({ appState: nextAppState });
  };

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>Welcome to React Native!</Text>
        <Text style={styles.instructions}>To get started, edit App.js</Text>
        <Text style={styles.instructions}>{instructions}</Text>
      </View>
    );
  }
}
...
```

For me using my code the issue isnt fixed changing _android:launchMode="singleTop"_. The android app is unique, the rendered layout by RN isnt.

Full project in gitgub repo at[RN59RootTag](https://github.com/castocolina/RN59RootTag)

---

## More

#### Create the project to reproduce

    npm i -g react-native;
    react-native init RN59RootTag;
    cd RN59RootTag;
    npm i;
    npm audit;
    npm audit fix -f;

#### Run

    adb devices;
    # Debug mode
    react-native run-android;
    # Release mode
    react-native run-android --variant=release;

#### Debug

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

- My Devices:

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

> > ```
> > [ro.build.version.release]: [7.1.2]
> > [ro.build.version.sdk]: [25]
> > [ro.product.brand]: [Zebra]
> > [ro.product.manufacturer]: [Zebra Technologies]
> > [ro.product.model]: [TC70x]
> > ```
