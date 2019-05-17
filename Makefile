PACKAGE_NAME=com.rn59roottag
APK_FOLDER=./android/app/build/outputs/apk
SIGN_STORE=rnroottag-app.jks
SIGN_STORE_PASS=1234567890
SIGN_KEY_ALIAS=rnroottag-app-key
SIGNED_FILE=rnroottagapp-release-signed.apk
DEFAUL_RELEASE_FILE=app-release.apk

run-android: remove-local-apk remove-phone-apk
	cd android && ./gradlew clean
	export REACT_DEBUGGER="open -g 'rndebugger://set-debugger-loc?port=8081' ||"
	bash appcenter-post-clone.sh && react-native run-android
	watchman-make -p '*.js' 'app/**/*.js' 'android/**/*.java' 'assets/**/*.*' \
	  --run "react-native run-android"

build-install-release: build-release install-release

# Build bundle release version
build-release: remove-local-apk
	cd android && ./gradlew clean
	cd android && ./gradlew assembleRelease
	# make sign-apk
	ls -laR ${APK_FOLDER}/

install-release: remove-phone-apk
	adb -d install -r ${APK_FOLDER}/release/${DEFAUL_RELEASE_FILE}
	make launch

launch:
	adb shell am start -n ${PACKAGE_NAME}/.MainActivity

remove-local-apk:
	rm -vrf ${APK_FOLDER}

remove-phone-apk:
	( adb shell pm list packages | grep $(PACKAGE_NAME) && adb -d uninstall $(PACKAGE_NAME) ) \
		|| echo "$(PACKAGE_NAME) NOT FOUND"

create-keystore:
	( keytool -list -keystore ${SIGN_STORE} -storepass ${SIGN_STORE_PASS} | grep ${SIGN_KEY_ALIAS} && \
		keytool -delete -alias ${SIGN_KEY_ALIAS} -keystore ${SIGN_STORE} -storepass ${SIGN_STORE_PASS} ) \
		|| echo "NO EXISTE ALIAS"

	keytool -genkey -v -noprompt -alias ${SIGN_KEY_ALIAS} -keyalg RSA -keysize 2048 -validity 10000 \
		-dname "CN=store9.walmart.cl, OU=ID, O=Walmart, L=Huechuraba, S=Santiago, C=CL" \
		-keystore ${SIGN_STORE} \
		-storepass ${SIGN_STORE_PASS} -keypass ${SIGN_STORE_PASS}

	keytool -importkeystore -srckeystore ${SIGN_STORE} -destkeystore ${SIGN_STORE} -deststoretype pkcs12 \
		-srcstorepass ${SIGN_STORE_PASS} -deststorepass ${SIGN_STORE_PASS}
	rm -rvf ${SIGN_STORE}.old*
	mv ${SIGN_STORE} android/app

sign-apk:
	cp -fv ${APK_FOLDER}/release/${DEFAUL_RELEASE_FILE} ${APK_FOLDER}/release/${SIGNED_FILE}

	jarsigner -sigalg SHA1withRSA -digestalg SHA1 -keystore ${SIGN_STORE} ${APK_FOLDER}/release/${SIGNED_FILE} \
		${SIGN_KEY_ALIAS} -storepass ${SIGN_STORE_PASS}

screencap-android:
	adb shell screencap /sdcard/screencap.png
	adb pull /sdcard/screencap.png
	convert -resize 700x700 screencap.png screencap.png
