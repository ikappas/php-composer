module Composer
  module Package
    module Loader

      # Loads a package from the project root package
      # @author Ioannis Kappas <ikappas@devworks.gr>
      class ProjectRootPackageLoader

        def initialize(loader)
          @loader = loader
        end

        # Load a project ref
        # Param:  string|JsonFile json A filename, json string or JsonFile instance to load the package from
        # Returns: Composer::Package::Package
        def load(project, ref)

          config = Composer::Json::JsonFile.parse_json(
            project.repository.blob_at(ref.target, 'composer.json')
          )

          @loader.load(config)
        end

      end
    end
  end
end
