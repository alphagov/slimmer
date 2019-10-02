require 'rake'

namespace :slimmer do
  desc "Symlink from public directory to static directory"
  task :link do
    path_to_static = "../static/public"
    path_to_public = "public"
    commands = ["cd #{path_to_public}"]
    Dir.glob("../static/public/*") { |f|
      commands << "ln -s #{path_to_static}/#{f}"
    }
    commands << ["cd .."]
    run commands.join(" && ")
  end
end
