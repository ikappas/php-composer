module Helpers

  def get_version_parser
    if @parser
      return @parser
    end
    @parser = Composer::Package::Version::VersionParser.new
    @parser
  end

  def get_version_constraint(operator, version)
    constraint = Composer::Package::LinkConstraint::VersionConstraint.new(
      operator, get_version_parser.normalize(version)
    )
    constraint.pretty_string = operator + ' ' + version;
    constraint
  end

  def get_package(name, version, class_name = 'Composer::Package::Package')
    norm_version = get_version_parser.normalize(version)
    Object.const_get(class_name).new(
        name,
        norm_version,
        version
    )
  end

  def get_alias_package(package, version)
    norm_version = get_version_parser.normalize(version)
    Composer::Package::AliasPackage.new(
       package,
       norm_version,
       version
    )
  end

  def ensure_dir_exists_and_clear(directory)
    if Dir.exists?(directory)
      Dir.rmdir(directory)
    end
    Dir.mkdir(directory, 0777)
  end

end
