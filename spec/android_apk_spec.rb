require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require "pp"

describe "AndroidApk" do
  apk = nil  
  sample_file_path = File.dirname(__FILE__) + "/mock/vibee.apk"
  dummy_file_path = File.dirname(__FILE__) + "/mock/dummy.apk"
  it "Sample apk file exist" do
    File.exist?(sample_file_path).should == true
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
  end

  it "Can read apk information" do
    apk.icon.should == "res/drawable/appicon.png"
    apk.label.should == "vibee"
    apk.package_name.should == "net.hakamastyle.app.vibee"
    apk.version_code.should == "1"
    apk.version_name.should == "1"
  end

  it "Icon file unzip" do
    apk.icon_file.should_not == nil
  end

end
