# Android APK

[![Circle CI](https://circleci.com/gh/kyoro/android_apk.svg?style=svg)](https://circleci.com/gh/kyoro/android_apk)

This gem allows you to analyze Android application package file (*i.e.* .apk files.)


## Prerequisite

You must set PATH to `$ANDROID_SDK_HOME/platform-tools` and make sure the `aapt` command executable.

## Installation

Append to Gemfile:

```
gem 'android_apk'
```

or run on your terminal:

```
gem install android_apk
```

## Usage

```ruby
require 'android_apk'

apk = AndroidApk.analyze("/path/to/apkfile.apk")

apk.sdk_version
# => 14

apk.target_sdk_version
# => 26

apk.label
# => "Sample"

apk.package_name
# => "com.example.sample"

apk.version_code
# => 1

apk.version_name
# => "1.0"

apk.labels.length
# => 2

apk.labels['ja']
# => 'サンプル'

apk.signature
# => "c1f285f69cc02a397135ed182aa79af53d5d20a1"

apk.icons.length
# => 5

apk.icon
# => "res/mipmap-anydpi-v26/ic_launcher.xml"

apk.icon_file
# => File (png/xml)

apk.icon_file('hdpi')
# => File (png/xml)

apk.icon_file('hdpi', true)
# => File (png)

apk.dpi_str(240)
# => "hdpi"
```


# License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Copyright &copy; 2017 Kyosuke Inoue <kyoro@hakamastyle.net>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
