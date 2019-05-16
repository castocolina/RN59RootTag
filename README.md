# RN59RootTag

ReactNative issue when send the app 2 background and return from. Create multiple instances of rootTag

---

### Create Project

    npm i -g react-native
    react-native init RN59RootTag
    cd RN59RootTag
    npm i
    npm audit
    npm audit fix -f

### Simple run

    adb devices
    # Debug mode
    react-native run-android
    # Release mode
    react-native run-android --variant=release

### Debug

    export ANDROID_LOG_TAGS="*ActivityManager:V com.rn59roottag:V ReactNative:V ReactNativeBleManager:V ReactNativeJS:V *:S"
    # To see log history in device
    adb logcat
    # To see only current and future logs
    adb logcat -T "$(date +'%m-%d %H:%M:%S.000')"
