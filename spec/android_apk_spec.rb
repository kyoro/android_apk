# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require "pp"

describe "AndroidApk" do
  apk = nil  
  apk2 = nil
  icon_not_set_apk = nil
  sample_file_path = File.dirname(__FILE__) + "/mock/sample.apk"
  sample2_file_path = File.dirname(__FILE__) + "/mock/BarcodeScanner4.2.apk"
  icon_not_set_file_path = File.dirname(__FILE__) + "/mock/UECExpress.apk"
  dummy_file_path = File.dirname(__FILE__) + "/mock/dummy.apk"

  it "Sample apk file exist" do
    File.exist?(sample_file_path).should == true
    File.exist?(sample2_file_path).should == true
  end

  it "Library can not read apk file" do
    apk = AndroidApk.analyze(sample_file_path + "dummy")
    apk.should == nil
  end
  
  it "Library can not read invalid apk file" do
    apk = AndroidApk.analyze(dummy_file_path)
    apk.should == nil
  end

  it "Library can read apk file" do
    apk = AndroidApk.analyze(sample_file_path)
    apk.should_not == nil
    apk2 = AndroidApk.analyze(sample2_file_path)
    apk2.should_not == nil
  end

  it "Can read apk information" do
    apk.icon.should == "res/drawable-mdpi/ic_launcher.png"
    apk.label.should == "sample"
    apk.package_name.should == "com.example.sample"
    apk.version_code.should == "1"
    apk.version_name.should == "1.0"
    apk.sdk_version.should == "7"
    apk.target_sdk_version.should == "15"
    apk.labels.length.should == 1
    apk.labels['ja'].should == 'サンプル'
  end

  it "Can read signature" do
    apk.signature.should == "c1f285f69cc02a397135ed182aa79af53d5d20a1"
  end

  it "Icon file unzip" do
    apk.icons.length.should == 3
    apk.icon_file.should_not == nil
    apk.icon_file(apk.icons.keys[0]).should_not == nil
  end

  it "Can read apk information 2" do
    apk2.icon.should == "res/drawable/launcher_icon.png"
    apk2.label.should == "Barcode Scanner"
    apk2.package_name.should == "com.google.zxing.client.android"
    apk2.version_code.should == "84"
    apk2.version_name.should == "4.2"
    apk2.sdk_version.should == "7"
    apk2.target_sdk_version.should == "7"
    apk2.labels.length.should == 29
    apk2.labels['ja'].should == 'QRコードスキャナー'
  end

  it "Icon file unzip 2" do
    apk2.icons.length.should == 3
    apk2.icon_file.should_not == nil
    apk2.icon_file(120).should_not == nil
    apk2.icon_file("120").should_not == nil
    apk2.icon_file(160).should_not == nil
    apk2.icon_file(240).should_not == nil
  end

  it "Can read signature 2" do
    apk2.signature.should == "e460df681d330f93f92e712cd79985d99379f5e0"
  end

  it "If icon has not set returns nil" do
    icon_not_set_apk = AndroidApk.analyze(icon_not_set_file_path)
    icon_not_set_apk.should_not == nil
    icon_not_set_apk.icon_file.should == nil
  end

end
