$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'eventstore'

require 'json'

trap 'TTIN' do
  Thread.list.each do |thread|
    puts "Thread TID-#{thread.object_id.to_s(36)}"
    puts thread.backtrace.join("\n")
    puts "\n\n\n"
  end
end
