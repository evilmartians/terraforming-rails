# Fight the flakiness

Tips on detecting and solving flaky tests in Rails apps.

## Make sure tests run in random order

For example, `config.order :random` for RSpec.

## Make sure you use transactional tests

For example, `config.transactional_tests = true` for RSpec.

## Avoid `before(:all)` (unless you sure it's safe)

- Use [rubocop-rspec](https://github.com/rubocop-hq/rubocop-rspec) `RSpec/BeforeAfterAll` cop to find `before(:all)` usage
- Consider replacing with `before` or [`before_all`](https://test-prof.evilmartians.io/#/before_all)

## Travel through time and always return back

- Find leaking time travelling with [`TimecopLinter`](../tools/timecop_linter)
- Add `config.after { Timecop.return }`
- If you rely on time zones in the app, randomize the current time zone in tests (e.g. with [`zonebie`](https://github.com/alindeman/zonebie)) to make sure your tests don't depend on it.

## Clear cache / in-memory stores after each test

For example, for ActiveJob (to avoid [`have_enqueued_job`](https://relishapp.com/rspec/rspec-rails/docs/matchers/have-enqueued-job-matcher) matcher catching jobs from other tests):
  
```ruby
RSpec.configure do |config|
  config.after do
    # Clear ActiveJob jobs
    if defined?(ActiveJob) && ActiveJob::QueueAdapters::TestAdapter === ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear
      ActiveJob::Base.queue_adapter.performed_jobs.clear
    end
  end
end
```

## Generated data must be random enough

- Respect DB uniquness constraint in your factories (check with [`FactoryLinter`](../tools/factory_linter))

## Make sure tests pass offline

Tests should not depend on the unknown outside world.

- Wrap deps into testable modules/classes:
  
```ruby
# Make Resolv testable
module Resolver
  class << self
    def getaddress(host)
      return "1.2.3.4" if test?
      Resolv.getaddress(host)
    end

    def test!
      @test = true
    end

    def test?
      @test == true
    end
  end
end

# rspec_helper.rb

Resolver.test!
```

- Provide mock implementations:
  
```ruby
# App-specific wrapper over S3
class S3Object
  attr_reader :key, :bucket
  def initialize(bucket_name, key = SecureRandom.hex)
    @key = key
    @bucket = bucket_name
  end

  def get
    $s3.get_object(bucket: @bucket, key: @key).body.read
  end

  def put!(file)
    $s3.put_object(bucket: @bucket, key: @key, body: file)
  end
end

# Mock for S3Object to avoid calling real AWS
class S3ObjectMock < S3Object
  def get
    @file.rewind
    @file.read.force_encoding(Encoding::UTF_8)
  end

  def put!(file)
    @file = file
  end
end

# in test
before { stub_const "S3Object", S3ObjectMock }
```

## Do not `sleep` in tests

When writing System Tests avoid indeterministic `sleep 1` and
use `have_xyz` matchers instead–they keep internal timeout and could _wait_ for
event to happened.

Remember: **Time is relative** (Einstein).

## Match arrays with `match_array`

If you don't need to the exact ordering, use [`match_array`](https://www.rubydoc.info/github/rspec/rspec-expectations/RSpec/Matchers:match_array) matcher instead of `eq([...])`.

## Testing `NotFound` with random IDs

If you test not-found-like behaviour you can make up non-existent IDs like this:

```ruby
expect { User.find(1234) }.to raise_error(ActiveRecord::RecordNotFound)
```

There is a change that the record with this ID exists (if you have `before`/`before(:all)` or fixtures).

A better "ID" for this purposes is "-1":

```ruby
expect { User.find(-1) }.to raise_error(ActiveRecord::RecordNotFound)
```

## Read more

- [Tests that sometimes fail](https://samsaffron.com/archive/2019/05/15/tests-that-sometimes-fail) by Sam Saffron
- [Fixing Flaky Tests Like a Detective](https://speakerdeck.com/sonjapeterson/fixing-flaky-tests-like-a-detective) by Sonja Peterson
