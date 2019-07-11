# Factory Linter

Perform different checks against [Factory Bot](https://github.com/thoughtbot/factory_bot) factory definitions:

- Load all defined factories (**NOTE:** requires `eager_load = true`)
- Run defined checks against each factory
- Fails (`exit(1)`) when at aleast one check generated an error.

List of checks:

- `UniquenessCheck` – verifies that an attribute is defined using sequence if it has a corresponding unique index. Requires an attribute to be defined using a sequence to be 100% sure that it's unique (Faker doesn't guarantee this by default). Recognizes values generated with `SecureRandom`.

## Usage

- Put [`factory_linter.rb`](./factory_linter.rb) into `lib/` folder
- Add to `Rakefile` (or create a separate Rake task):

```ruby
desc "Lint factory definitions"
task factory_lint: :environment do
  require_relative "./lib/factory_lint"
  FactoryLinter.call
end
```

- Run Rake task:

```sh
$ bundle exec rake factory_lint


Factory lint detected the following errors:

- :city should use a sequence for :name attribute, 'cause it has a uniqueness constraint
```
