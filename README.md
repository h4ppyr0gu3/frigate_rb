# FrigateRb

FrigateRb is a Ruby wrapper for the [Frigate](https://frigate.video) API

## Installation

Add this line to your application's Gemfile:
it might not be on rubygems

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add frigate_rb
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install frigate_rb
```

## Usage

### Single instance (backward compatible)

Configure the gem with your credentials then go to town:

```ruby
FrigateRb.configure do |config|
  config.frigate_https_url = ENV['FRIGATE_HTTPS_URL']
  config.frigate_username = ENV['FRIGATE_USERNAME']
  config.frigate_password = ENV['FRIGATE_PASSWORD']
end

# anything can then be called — auth is done when necessary
FrigateRb::Event.all
selected_event = FrigateRb::Event.find('1759227780.368255-48pfjk')
ten = FrigateRb::Event.where({limit: 10})
```

### Multiple instances (0.2.x)

Register and use multiple Frigate nodes side-by-side. Each named client
carries its own configuration, cookie jar, and Faraday connections:

```ruby
FrigateRb.configure(:frigate) do |c|
  c.frigate_https_url = "https://nvr1:8971"
  c.frigate_username  = "admin"
  c.frigate_password  = "secret"
end

FrigateRb.configure(:frigate2) do |c|
  c.frigate_https_url = "https://nvr2:8971"
  c.frigate_username  = "admin"
  c.frigate_password  = "other"
end

FrigateRb.client(:frigate)   # memoized Client + cookie jar
FrigateRb.client(:frigate2)  # separate memoized Client + cookie jar
FrigateRb.clients            # { frigate: Client, frigate2: Client }

# Pass the client explicitly — the returned object remembers it
event = FrigateRb::Event.find(id, client: FrigateRb.client(:frigate2))
event.mark_as_reviewed       # uses :frigate2, not :frigate
```

#### Registry helpers

```ruby
# Remove a client when its Frigate instance row is destroyed
FrigateRb.unregister(:frigate2)

# Rebuild a client after a config update (new cookie session)
FrigateRb.reload(:frigate) { |c| c.frigate_https_url = new_url }

# Clear everything (primarily for tests)
FrigateRb.reset!
```

#### MQTT

The MQTT broker stays one shared environment — configure it on the default
(`:default`) configuration only:

```ruby
FrigateRb.configure do |c|
  c.frigate_mqtt_url      = ENV['FRIGATE_MQTT_URL']
  c.frigate_mqtt_username = ENV['FRIGATE_MQTT_USERNAME']
  c.frigate_mqtt_password = ENV['FRIGATE_MQTT_PASSWORD']
end
```

You can then use the MQTT listener to process objects into this gem's format:

```ruby
FrigateRb::Mqtt::Listener.run do |type, object|
    # do something
    # types are event, review, or raw frigate topic
    # object in the case of raw topic would be the message
    # objects in the case of event or review would be a class
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/h4ppyr0gu3/frigate_rb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
