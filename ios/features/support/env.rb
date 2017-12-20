require 'calabash-cucumber/cucumber'


def is_ipad()
  #puts "simulator device: %s" % server_version()['simulator_device']
  return server_version()['simulator_device'] == 'iPad';
end

def is_iphone()
  return ! is_ipad()
end

