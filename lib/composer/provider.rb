module Composer
  class Provider

    BLANK_PROVIDER = { "packages"=>{} }

    def initialize(project)
      @project = project
      @package_dumper = Composer::Package::Dumper::HashDumper.new
    end

    def add_package(package)

      raise ArgumentError, 'package must be specified' unless package
      # raise TypeError, 'package must be a subclass of Composer::Package::Package' unless package.kind_of?(Composer::Package::Package)

      name = package.name
      pretty_version = package.pretty_version

      packages[name] ||= {}
      packages[name][pretty_version] = @package_dumper.dump(package)

      if packages[name].length >= 2
        packages[name].keys.sort.each { |k| packages[name][k] = packages[name].delete k }
      end

    end

    def rm_package(package)

      raise ArgumentError, 'package must be specified' unless package
      # raise TypeError, 'package must be a subclass of Composer::Package::Package' unless package.kind_of?(Composer::Package::Package)

      name = package.name
      pretty_version = package.pretty_version

      if has_package?(name, pretty_version)
        packages[name].delete(pretty_version)
        if packages[name].empty?
          packages.delete(name)
        elsif packages[name].length >= 2
          packages[name].keys.sort.each { |k| packages[name][k] = packages[name].delete k }
        end
      end

    end

    def clear_packages
      @packages = {}
    end

    def has_package?(name, pretty_version=nil)
      if pretty_version
        packages.key?(name) ? packages[name].key?(pretty_version) : false
      else
        packages.key?(name)
      end
    end

    def has_packages?
      !packages.empty?
    end

    def save_or_delete
      if has_packages?
        File.open(filepath, "w") { |f| f.write(content) }
      else
        File.delete(filepath) unless not File.exist?(filepath)
      end
    end

    def filename
      "project-#{@project.id}.json"
    end

    def sha1
      Digest::SHA1.hexdigest content
    end

    private

    def packages
      @packages ||= File.exist?(filepath) ? File.open(filepath, "r") { |f| ActiveSupport::JSON.decode(f.read)["packages"] rescue {} } : {}
    end

    def content
      { 'packages' => packages }.to_json
    end

    def filepath
      File.join(File.realpath(Rails.root.join('public', 'p')), filename)
    end

  end
end
