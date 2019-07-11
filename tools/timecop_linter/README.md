# Timecop Linter

Warn if [Timecop](https://github.com/travisjeffery/timecop) hasn't been returned at the end of the top-level example group.

If you do not call `Timecop.return`, you might want to use this script to ensure that you always `return`
in-place.

## Usage

**NOTE:** RSpec only.

- Drop the [`timecop_linter_rspec.rb`](./timecop_linter_rspec.rb) script into `spec/support` folder
- Load it in your `rspec_helper.rb`
- Run tests and watch for warnings:

```sh
$ bundle exec rspec

📛 ⏰ 📛 Timecop hasn't returned at the end of the test file!
File: spec/controllers/users_controller_spec.rb
```
