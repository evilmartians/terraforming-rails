# Templates Tracker

Track view templates used during the tests execution and print the list of used and, which is more importantly, unused templates.

## Usage

**NOTE:** the provided script is RSpec only. The tracker though doesn't depend on the testing framework and could be easily extracted.

**NOTE:** has been tested only with Rails 4.2.

- Drop the [`templates_tracker_rspec.rb`](./templates_tracker_rspec.rb) script into `spec/support` folder
- Load it in your `rspec_helper.rb`
- Run specs with `TT=1` env var:
 
```
$ TT=1 bundle exec rspec

======== Unused Templates =========

/app/app/views/home/index.html.erb
/app/app/views/housekeeping/scheduling/index.html.erb
```

To print used templates use "debug" mode:

```
$ TT=debug bundle exec rspec

======== Used Templates =========

/app/app/views/users/index.html.erb
...

======== Unused Templates =========

/app/app/views/home/index.html.erb
/app/app/views/housekeeping/scheduling/index.html.erb
```
