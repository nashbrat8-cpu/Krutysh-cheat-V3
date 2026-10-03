#!/data/data/com.termux/files/usr/bin/bash
set -e
SDK=$ANDROID_HOME/platforms/android-35/android.jar
KEY=~/.release.keystore
ALIAS=krutysh
PASS=krutysh123
rm -rf build
mkdir -p build/gen build/obj build/apk build/dex
aapt2 compile --dir res -o build/apk/res.zip
aapt2 link -o build/apk/app.unsigned.apk -I $SDK --manifest AndroidManifest.xml --java build/gen build/apk/res.zip
javac -source 8 -target 8 -bootclasspath $SDK -cp $SDK -d build/obj $(find src build/gen -name "*.java")
d8 --output build/dex build/obj/com/example/hello/*.class
cd build/dex && zip -r ../apk/classes.dex classes.dex && cd ../..
cd build/apk && cp app.unsigned.apk app.apk && zip -u app.apk classes.dex && cd ../..
apksigner sign --ks $KEY --ks-key-alias $ALIAS --ks-pass pass:$PASS --key-pass pass:$PASS --out build/apk/app-signed.apk build/apk/app.apk
echo "DONE"
