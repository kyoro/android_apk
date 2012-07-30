require "tmpdir"
require "pp"
class AndroidApk
  attr_accessor :results,:label,:icon,:package_name,:version_code, :version_name, :filepath
  def self.analyze(filepath)
    return nil unless File.exist?(filepath)
    apk = AndroidApk.new
    command = "aapt dump badging " + filepath + " 2>&1"
    results = `#{command}`
    if results.index("ERROR: dump failed")
      return nil
    end
    apk.filepath = filepath
    apk.results = results
    results.split("\n").each do |line|
      info = line.split("\s")
      # application info
      if info[0] == "application:"
        apk.label = info[1].split("'")[1]
        apk.icon = info[2].split("'")[1]
      end
      #package 
      if info[0] == "package:"
        apk.package_name = info[1].split("'")[1]
        apk.version_code = info[2].split("'")[1]
        apk.version_name = info[3].split("'")[1]
      end
    end
    return apk
  end

  def icon_file
    Dir.mktmpdir do |dir|
      command = sprintf("unzip %s -d %s 2>&1",self.filepath,dir)
      results = `#{command}`
      path =  dir + "/" + self.icon 
      return nil unless  File.exist?(path)
      return path
    end
  end

end
