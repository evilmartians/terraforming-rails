# Gem Tracker

Tracks gems that are used by the application during the tests run.

Compares this set with the gems specified in Gemfile and report which gems haven't left any trace during the execution (in `ObjectSpace`).

## Usage

- Drop the [`gem_tracker.rb`](./gem_tracker.rb) script into `spec/support` folder
- Load it in your `rspec_helper.rb`
- Run specs with `GEM_TRACK=1` env var:

```sh
$ GEM_TRACK=1 bundle exec rspec

Maybe unused gems:

activerecord-postgres_enum-0.3.0
avatax-18.12.0
aws-sdk-2.10.9
```
