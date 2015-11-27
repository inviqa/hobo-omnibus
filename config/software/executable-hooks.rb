#
# Copyright:: Copyright (c) 2015 The Inviqa Group Limited
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
name "executable-hooks"

default_version "1.3.2"
dependency "rubygems"
dependency "hem"

build do
  block "Add executable-hooks gem" do
    gem "install executable-hooks" \
        " --version '#{version}'"
  end
end