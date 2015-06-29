# capistrano-runit-rake

Capistrano3 tasks for manage long running rake tasks or daemons via runit supervisor.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-runit-rake'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-runit-rake

## Tasks

* `runit:rake:start` -- start all rake tasks.
* `runit:rake:stop` -- stop all rake tasks.
* `runit:rake:restart` -- restart all rake tasks.
* `runit:rake:foo:setup` -- setup `foo` rake task service.
* `runit:rake:foo:enable` -- enable `foo` rake task service.
* `runit:rake:foo:disable` -- disable `foo` rake task service.
* `runit:rake:foo:start` -- start `foo` rake task service.
* `runit:rake:foo:stop` -- stop `foo` rake task service.

## Variables

* `runit_rake_role` -- what host roles uses runit to run rake long running tasks. Default value: `:app`
* `runit_rake_foo_role` -- what host roles uses runit to run rake long running task with key `foo`. Default value: `:app`
* `runit_rake_tasks` -- Hash of rake tasks. Default value: `{}`

## Usage

Add this line in `Capfile`:
```ruby
require 'capistrano/runit/rake'
```
Add your tasks in `config/deploy.rb`:

```ruby
set :runit_rake_tasks, {
  'foo' => 'daemon:bar'
}
set :runit_rake_foo_role, :db # change role for foo rake task
```

## Contributing

1. Fork it ( https://github.com/capistrano-runit/rake/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
