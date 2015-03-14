require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

VENDORED_PROTO = 'vendor/proto/ClientMessageDtos.proto'
PROTO_URL = 'https://raw.githubusercontent.com/EventStore/EventStore/oss-v3.0.1/src/Protos/ClientAPI/ClientMessageDtos.proto'
PROTO_DIR = 'lib/eventstore'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc 'Update the protobuf messages definition'
task :proto do
  system("wget -O #{VENDORED_PROTO} #{PROTO_URL}")
  system("mkdir -p #{PROTO_DIR}")
  beefcake_bin = Bundler.bin_path.join('protoc-gen-beefcake').to_s
  if system("BEEFCAKE_NAMESPACE=Eventstore protoc --plugin=#{beefcake_bin} --beefcake_out lib/eventstore #{VENDORED_PROTO}")
    FileUtils.mv('lib/eventstore/ClientMessageDtos.pb.rb', 'lib/eventstore/messages.rb')
    system("sed -i '' 's/module Eventstore/class Eventstore/' lib/eventstore/messages.rb")
  end
end
