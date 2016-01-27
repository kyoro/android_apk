require 'tmpdir'
require 'shellwords'
require 'open3'

class AndroidApk
  attr_accessor :results,:label,:labels,:icon,:icons,:package_name,:version_code,:version_name,:sdk_version,:target_sdk_version,:filepath

  APPLICATION_TAG_NAME = 'application'
  class AndroidManifestValidateError < StandardError
  end

  def self.analyze(filepath)
    return nil unless File.exist?(filepath)
    apk = AndroidApk.new
    command = "aapt dump badging #{filepath.shellescape} 2>&1"
    results = `#{command}`
    if $?.exitstatus != 0 or results.index("ERROR: dump failed")
      return nil
    end
    apk.filepath = filepath
    apk.results = results

    _validate_aapt(results)
    vars = _parse_aapt(results)

    # application info
    apk.label = vars['application-label']
    apk.icon = vars['application']['icon']

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

  def icon_file(dpi = nil, want_png = false)
    icon = dpi ? self.icons[dpi.to_i] : self.icon
    icon = icon.first if icon.is_a?(Array)
    return nil if icon.empty?

    if want_png && icon.end_with?('.xml')
      dpis = dpi_str(dpi)
      icon.gsub! %r{res/drawable-anydpi-v21/([^/]+)\.xml}, "res/drawable-#{dpis}-v4/\\1.png"
    end

    Dir.mktmpdir do |dir|
      command = "unzip #{self.filepath.shellescape} #{icon.shellescape} -d #{dir.shellescape} 2>&1"
      results = `#{command}`
      path =  dir + "/" + icon 
      return nil unless File.exist?(path)
      return File.new(path,'r')
    end
  end

  def dpi_str(dpi)
    case dpi.to_i
      when 120
        'ldpi'
      when 160
        'mdpi'
      when 240
        'hdpi'
      when 320
        'xhdpi'
      when 480
        'xxhdpi'
      when 640
        'xxxhdpi'
      else
        'xxxhdpi'
    end
  end

  def signature
    command = "unzip -p #{self.filepath.shellescape} META-INF/*.RSA META-INF/*.DSA | keytool -printcert | grep SHA1:"
    output, _, status = Open3.capture3(command)
    return if status != 0 || output.nil? || !output.index('SHA1:')
    val = output.scan(/(?:[0-9A-Z]{2}:?){20}/)
    return nil if val.nil? || val.length != 1
    return val[0].gsub(/:/, "").downcase
  end

  # workaround for https://code.google.com/p/android/issues/detail?id=160847
  def self._parse_values_workaround(str)
    return nil if str.nil?
    str.scan(/^'(.+)'$/).map{|v| v[0].gsub(/\\'/, "'")}
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
    values =
        if info[0].start_with?('application-label')
          _parse_values_workaround info[1]
        else
          _parse_values info[1]
        end
    return info[0], values
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

  def self._validate_aapt(results)
    # Check multi application tag from AndroidManifest.xml
    application_tag = []
    results.split("\n").each do |line|
      key, value = _parse_line(line)
      application_tag.push(value) if key == APPLICATION_TAG_NAME
    end
    raise AndroidManifestValidateError, 'Not support multi application tag' if application_tag.count > 1
  end
end
