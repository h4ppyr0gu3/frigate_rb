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

Configure the gem with your credentials then go to town

```ruby
FrigateRb.configure do |config|
  config.frigate_https_url = ENV['FRIGATE_HTTPS_URL']
  config.frigate_username = ENV['FRIGATE_USERNAME']
  config.frigate_password = ENV['FRIGATE_PASSWORD']
end

# anything can then be called
# auth will be done when necessary

FrigateRb::Event.all

selected_event = FrigateRb::Event.find('1759227780.368255-48pfjk')

ten = FrigateRb::Event.where({limit: 10})
```

you can then use the MQTT listener as well to process objects to this gems format

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
