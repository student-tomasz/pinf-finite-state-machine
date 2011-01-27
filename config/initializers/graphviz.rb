require 'graphviz'

Mime::Type.register 'image/png',     :png
Mime::Type.register 'image/svg+xml', :svg
Mime::Type.register 'text/plain',    :dot

require File.expand_path('../../../lib/monkey_patches/graphviz', __FILE__)
