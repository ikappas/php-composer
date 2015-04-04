# external
require 'json'
require 'json-schema'

# /
require 'composer/version'
require 'composer/error'

# /json
require 'composer/json/json_validaton_error'
require 'composer/json/json_file'
require 'composer/json/json_formatter'

# /package
require 'composer/package/base_package'
require 'composer/package/package'
require 'composer/package/complete_package'
require 'composer/package/alias_package'
require 'composer/package/root_alias_package'
require 'composer/package/root_package'
require 'composer/package/link'

# /package/dumper
require 'composer/package/dumper/hash_dumper'

# /package/link_constraint
require 'composer/package/link_constraint/base_constraint'
require 'composer/package/link_constraint/empty_constraint'
require 'composer/package/link_constraint/specific_constraint'
require 'composer/package/link_constraint/version_constraint'
require 'composer/package/link_constraint/multi_constraint'

# /package/loader
require 'composer/package/loader/hash_loader'
require 'composer/package/loader/json_loader'

# /package/version
require 'composer/package/version/version_parser'
require 'composer/package/version/version_selector'

# Dir[File.join(File.dirname(__FILE__), "composer/package/dumper/*.rb")].each {|file| require file }
# Dir[File.join(File.dirname(__FILE__), "composer/package/link_constraint/*.rb")].each {|file| require file }
# Dir[File.join(File.dirname(__FILE__), "composer/package/loader/*.rb")].each {|file| require file }
# Dir[File.join(File.dirname(__FILE__), "composer/package/version/*.rb")].each {|file| require file }

# /repository
require 'composer/repository/array_repository'
require 'composer/repository/writeable_array_repository'
require 'composer/repository/filesystem_repository'

module Composer
end
