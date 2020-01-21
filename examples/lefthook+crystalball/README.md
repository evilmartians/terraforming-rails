# [Lefthook] and [Crystalball]

Read this post for more information: [Lefthook, Crystalball, and git magic for smooth development experience](https://evilmartians.com/chronicles/lefthook-crystalball-and-git-magic).

## What does this example do

 1. Installs missing gems on `git pull` or branch checkout.

 1. Applies new database migrations on `git pull`.

 1. Rollbacks migrations that are present only on some feature branch on checkout from that branch to another.

 1. Runs only relevant part of your test suite (via [crystalball] gem) on `git push`, aborts push when the first spec is failed.

 1. Updates crystalball code execution maps once a week.

## Installation

Add required gems to your `Gemfile` and install them with `bundle install`:

```ruby
group :test do
  gem "crystalball", require: false
end

group :development do
  gem "git", require: false # it is a dependency of Crystalball, but it is better to declare it explicitly
  gem "lefthook", require: false
end
```

Copy lefthook configuration file `lefthook.yml` and directory `.lefthook` to your project.

[Set up Lefthook](https://github.com/Arkweid/lefthook/blob/master/docs/ruby.md):

```sh
lefthook install
```

Copy `config/crystalball.yml` file to your project

Setup your test suite to collect code coverage information:

```ruby
# spec/spec_helper.rb
if ENV["CRYSTALBALL"] == "true"
  require "crystalball"
  require "crystalball/rails"

  Crystalball::MapGenerator.start! do |config|
    config.register Crystalball::MapGenerator::CoverageStrategy.new
    config.register Crystalball::Rails::MapGenerator::I18nStrategy.new
    config.register Crystalball::MapGenerator::DescribedClassStrategy.new
  end
end
```

Generate code execution maps:

```sh
CRYSTALBALL=true bundle exec rspec
```

And that’s it!

[Lefthook]: https://github.com/Arkweid/lefthook "Fast and powerful Git hooks manager for any type of projects."
[Crystalball]: https://github.com/toptal/crystalball "Regression Test Selection library for your RSpec test suite."
