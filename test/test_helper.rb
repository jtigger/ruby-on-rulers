# test/test_helper.rb
require "rack/test"
require "test/unit"

# Make sure the local copy of "rulers" is loaded, below, not one installed in the gemset.
this_dir = File.join(File.dirname(__FILE__), "..")
$LOAD_PATH.unshift File.expand_path(this_dir)

require "rulers"