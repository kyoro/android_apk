#Android APK

[![Circle CI](https://circleci.com/gh/kyoro/android_apk.svg?style=svg)](https://circleci.com/gh/kyoro/android_apk)

This gem library is Android application package file (.apk) analyzer.
you can read any information of android apk files.

## Attention

You must set path to 'AndroidSDK/platform-tools'.
And you must can execute 'aapt' command.

## How to use

```
require 'android_apk'

apk = AndroidApk.analyze("/path/to/apkfile.apk")

apk.nil? # This file is invalid apk file.

apk.label #Application Name
apk.package_name #Package Name
apk.icon #Included Icon file in apk file
apk.version_code #Version Code
apk.version_name #Version Name
```

## License
This Library is using MIT license.

## Contact
Kyosuke INOUE < kyoro@hakamastyle.net>
