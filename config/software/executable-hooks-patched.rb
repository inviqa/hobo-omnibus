#
# Copyright:: Copyright (c) 2014 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This software makes sure that SSL_CERT_FILE environment variable is pointed
# to the bundled CA certificates that ship with omnibus. With this, Chef
# tools can be used with https URLs out of the box.
name "executable-hooks-patched"

source path: "#{project.files_path}/#{name}"

default_version "1.3.2"
dependency "executable-hooks"

build do
  block "Add patch for executable-hooks gem" do
    # gets directories for RbConfig::CONFIG and sanitizes them.
    def get_sanitized_gemconfig(config)
      ruby = windows_safe_path("#{install_dir}/embedded/bin/ruby")

      config_dir = Bundler.with_clean_env do
        command_output = %x|#{ruby} -e "puts Gem.#{config}"|.strip
        windows_safe_path(command_output)
      end

      if config_dir.nil? || config_dir.empty?
        raise "could not determine embedded ruby's Gem.#{config}"
      end

      config_dir
    end

    embedded_gem_default_dir = get_sanitized_gemconfig('default_dir')

    source_patch      = File.join(project_dir, "default", "regenerate_binstubs_command.patch.rb")
    destination_file = File.join(embedded_gem_default_dir, "gems/executable-hooks-1.3.2/lib/executable-hooks/regenerate_binstubs_command.rb")

    FileUtils.cp source_patch, destination_file
  end
end