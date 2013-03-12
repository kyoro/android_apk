require "tmpdir"
require "pp"
class AndroidApk
  attr_accessor :results,:label,:labels,:icon,:icons,:package_name,:version_code,:version_name,:sdk_version,:target_sdk_version,:filepath
  def self.analyze(filepath)
    return nil unless File.exist?(filepath)
    apk = AndroidApk.new
    command = "aapt dump badging '" + filepath + "' 2>&1"
    results = `#{command}`
    if $?.exitstatus != 0 or results.index("ERROR: dump failed")
      return nil
    end
    apk.filepath = filepath
    apk.results = results
    vars = _parse_aapt(results)

    # application info
    apk.label, apk.icon =
      vars['application'].values_at('label', 'icon')

    # package 
    apk.package_name, apk.version_code, apk.version_name =
      vars['package'].values_at('name', 'versionCode', 'versionName')

    # platforms
    apk.sdk_version = vars['sdkVersion']
    apk.target_sdk_version = vars['targetSdkVersion']

    # icons and labels
    apk.icons = Hash.new
    apk.labels = Hash.new
    vars.each_key do |k|
      k =~ /^application-icon-(\d+)$/ && apk.icons[$1.to_i] = vars[k]
      k =~ /^application-label-(\S+)$/ && apk.labels[$1] = vars[k]
    end

    return apk
  end

  def icon_file(dpi = nil)
    icon = dpi ? self.icons[dpi.to_i] : self.icon
    return nil if icon.empty?
    Dir.mktmpdir do |dir|
      command = sprintf("unzip '%s' '%s' -d '%s' 2>&1",self.filepath,icon,dir)
      results = `#{command}`
      path =  dir + "/" + icon 
      return nil unless File.exist?(path)
      return File.new(path,'r')
    end
  end

  def signature
    command = sprintf("unzip -p '%s' META-INF/*.RSA | keytool -printcert | grep SHA1: 2>&1", self.filepath)
    results = `#{command}`
    return nil if $?.exitstatus != 0 || results.nil? || !results.index('SHA1:')
    val = results.scan(/(?:[0-9A-Z]{2}:?){20}/)
    return nil if val.nil? || val.length != 1
    return val[0].gsub(/:/, "").downcase
  end

  def self._parse_values(str)
    return nil if str.nil?
    if str.index("='")
      # key-value hash
      vars = Hash[str.scan(/(\S+)='((?:\\'|[^'])*)'/)]
      vars.each_value {|v| v.gsub(/\\'/, "'")}
    else
      # values array
      vars = str.scan(/'((?:\\'|[^'])*)'/).map{|v| v[0].gsub(/\\'/, "'")}
    end
    return vars
  end

  def self._parse_line(line)
    return nil if line.nil?
    info = line.split(":", 2)
    return info[0], _parse_values( info[1] )
  end

  def self._parse_aapt(results)
    vars = Hash.new
    results.split("\n").each do |line|
      key, value = _parse_line(line)
      next if key.nil?
      if vars.key?(key)
        if (vars[key].is_a?(Hash) and value.is_a?(Hash))
          vars[key].merge(value)
        else
          vars[key] = [vars[key]] unless (vars[key].is_a?(Array))
          if (value.is_a?(Array))
            vars[key].concat(value)
          else
            vars[key].push(value)
          end
        end
      else
         vars[key] = value.nil? ? nil :
           (value.is_a?(Hash) ? value :
             (value.length > 1 ? value : value[0]))
      end
    end
    return vars
  end
end
