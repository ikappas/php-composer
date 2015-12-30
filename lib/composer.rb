# external
require 'json'

# project
module Composer

  GEM_VERSION = '1.0.0-alpha11'

  class Error < ::StandardError; end
  class ArgumentError < Error; end
  class TypeError < Error; end
  class UnexpectedValueError < Error; end
  class LogicError < Error; end
  class InvalidRepositoryError < Error; end

  module Json
    autoload :JsonFile, 'composer/json/json_file'
    autoload :JsonFormatter, 'composer/json/json_formatter'
    autoload :JsonValidationError, 'composer/json/json_validation_error'
  end

  module Package
    autoload :Package, 'composer/package/package'
    autoload :CompletePackage, 'composer/package/complete_package'
    autoload :AliasPackage, 'composer/package/alias_package'
    autoload :RootAliasPackage, 'composer/package/root_alias_package'
    autoload :RootPackage, 'composer/package/root_package'
    autoload :Link, 'composer/package/link'

    module Dumper
      autoload :HashDumper,'composer/package/dumper/hash_dumper'
    end

    module Loader
      autoload :HashLoader, 'composer/package/loader/hash_loader'
      autoload :JsonLoader, 'composer/package/loader/json_loader'
    end

    module Version
      autoload :VersionParser, 'composer/package/version/version_parser'
      autoload :VersionSelector, 'composer/package/version/version_selector'
    end
  end

  module Repository
    autoload :BaseRepository, 'composer/repository/base_repository'
    autoload :HashRepository, 'composer/repository/hash_repository'
    autoload :WritableHashRepository, 'composer/repository/writeable_hash_repository'
    autoload :FilesystemRepository, 'composer/repository/filesystem_repository'
    autoload :CompositeRepository, 'composer/repository/composite_repository'
  end

  module Util
    autoload :ComposerMirror, 'composer/util/composer_mirror'
  end

end
