#
# This file is used to configure the Omnibus projects in this repo. It contains
# some minimal configuration examples for working with Omnibus. For a full list
# of configurable options, please see the documentation for +omnibus/config.rb+.
#

# Build internally
# ------------------------------
# By default, Omnibus uses system folders (like +/var+ and +/opt+) to build and
# cache components. If you would to build everything internally, you can
# uncomment the following options. This will prevent the need for root
# permissions in most cases.
#
# Uncomment this line to change the default base directory to "local"
# -------------------------------------------------------------------
# base_dir './local'
#
# Alternatively you can tune the individual values
# ------------------------------------------------
cache_dir     File.dirname(__FILE__) + '/local/omnibus/cache'
git_cache_dir File.dirname(__FILE__) + '/local/omnibus/cache/git_cache'
source_dir    File.dirname(__FILE__) + '/local/omnibus/src'
# build_dir     './local/omnibus/build'
# package_dir   './local/omnibus/pkg'
# package_tmp   './local/omnibus/pkg-tmp'

# Windows architecture defaults - set to x86 unless otherwise specified.
# ------------------------------
windows_arch   %w{x86 x64}.include?((ENV['OMNIBUS_WINDOWS_ARCH'] || '').downcase) ?
                ENV['OMNIBUS_WINDOWS_ARCH'].downcase.to_sym : :x86

# Disable git caching
# ------------------------------
# use_git_caching false

# Enable S3 asset caching
# ------------------------------
# use_s3_caching true
# s3_access_key  ENV['S3_ACCESS_KEY']
# s3_secret_key  ENV['S3_SECRET_KEY']
# s3_bucket      ENV['S3_BUCKET']

build_retries 3
fetcher_retries 3
fetcher_read_timeout 120
append_timestamp false

# We limit this to 10 workers to eliminate transient timing issues in the
# way Ruby (and other components) compiles on some more esoteric *nixes.
workers 10

# Load additional software
# ------------------------------
# software_gems ['omnibus-software', 'my-company-software']
# local_software_dirs ['/path/to/local/software']

# ENV overrides
ENV['GEM_PATH'] = ENV['GEM_HOME'] = nil
