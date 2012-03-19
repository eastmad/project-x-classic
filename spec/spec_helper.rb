PROJECT_ROOT = File.absolute_path(File.join(File.dirname(__FILE__), ".."))

# Add the lib directory to our require load path
$:<< File.join(PROJECT_ROOT, "simple_object_world")
$:<< File.join(PROJECT_ROOT, "control_systems")

require_relative "../control_systems/impl_trade"
require_relative "../control_systems/impl_contact"
require_relative "../control_systems/impl_weaponry"
require_relative "../control_systems/impl_modification"
require_relative "../control_systems/dictionary"
require_relative "../control_systems/system_test_helper"
require_relative "../interface/system_message"
require_relative "../control_systems/ship_data"
require_relative "../simple_object_world/modification"
require_relative "../simple_object_world/trust_holder"
require_relative "../simple_object_world/trustee"
require_relative "../simple_object_world/location_link"
require_relative "../simple_object_world/location_point"
require_relative "../simple_object_world/simple_body"
require_relative "../simple_object_world/trader"
require_relative "../simple_object_world/trade"
require_relative "../simple_object_world/simple_game_object"
require_relative "../simple_object_world/contact"
require_relative "../simple_object_world/city"



