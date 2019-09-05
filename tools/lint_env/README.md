# Lint/Env cop

Checks that application code doesn't rely on env variables or env name.

Application code should know about the _magical environment_ and should rely
on the explicit configuration instead.

## Usage

- Copy [`lint_env.rb`](./lint_env.rb) to `lib/rubocop/cop/lint_env.rb`
- (optionally) Copy [`lint_env_spec.rb`](./lint_env_spec.rb) to `spec/lib/rubocop/cop/lint_env_spec.rb` (if you want to make and test changes)
- Add the following to your `.rubocop.yml`:

```yml
require:
  - lib/rubocop/cop/lint_env


Lint/Env:
  Enabled: true
  Include:
    - '**/*.rb'
  Exclude:
    - '**/config/environments/**/*'
    - '**/config/application.rb'
    - '**/config/environment.rb'
    - '**/config/puma.rb'
    - '**/config/boot.rb'
    - '**/spec/*_helper.rb'
    - '**/spec/**/support/**/*'
    - 'lib/generators/**/*'
```

- Run RuboCop.
