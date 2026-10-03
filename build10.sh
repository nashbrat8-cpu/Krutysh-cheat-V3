#!/bin/bash
set -e
SDK="$ANDROID_HOME/platforms/android-35/android.jar"
BUILD_TOOLS="$ANDROID_HOME/build-tools/35.0.0"
rm -rf build
mkdir -p build/gen build/obj build/apk build/dex
$BUILD_TOOLS/aapt2 compile --dir res -o build/apk/res.zip
$BUILD_TOOLS/aapt2 link -o build/apk/app.unsigned.apk -I $SDK --manifest AndroidManifest.xml --java build/gen build/apk/res.zip
javac -source 8 -target 8 -bootclasspath $SDK -cp $SDK -d build/obj $(find src build/gen -name "*.java")
$BUILD_TOOLS/d8 --output build/dex build/obj/com/example/hello/*.class
cd build/dex && zip -r ../apk/classes.dex classes.dex && cd ../..
cd build/apk && cp app.unsigned.apk app.apk && zip -u app.apk classes.dex && cd ../..
keytool -genkeypair -v -keystore release.keystore -alias krutysh -keyalg RSA -keysize 2048 -validity 10000 -storepass krutysh123 -keypass krutysh123 -dname "CN=Krutysh, OU=Dev, O=Krutysh, L=Moscow, ST=Moscow, C=RU"
$BUILD_TOOLS/apksigner sign --ks release.keystore --ks-key-alias krutysh --ks-pass pass:krutysh123 --key-pass pass:krutysh123 --out build/apk/app-signed.apk build/apk/app.apk
echo "DONE"
