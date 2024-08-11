require 'fluent-logger'

# API: FluentLogger.new(tag_prefix, options)
log = Fluent::Logger::FluentLogger.new(nil, :host => 'localhost', :port => 24224)
unless log.post("myapp.access", {"agent" => "foo"})
  p log.last_error # You can get last error object via last_error method
end

# output: myapp.access {"agent":"foo"}