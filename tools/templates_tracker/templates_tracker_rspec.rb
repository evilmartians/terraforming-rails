module TemplatesTracker
  class << self
    attr_reader :mode

    def start(mode)
      @mode = mode
      ActionView::Template.send(:prepend, TemplatesTracker::Ext)
    end

    def track(path)
      return unless path.start_with?(root)
      store[path] = 1
    end

    def print
      if mode == "debug"
        puts "\n======== Used Templates =========\n\n"
        puts used.join("\n")
      end
      puts "\n======== Unused Templates =========\n\n"
      puts unused.join("\n")
    end

    def used
      store.keys
    end

    def unused
      all - used
    end

    # FIXME: check other view paths (using config.paths)
    # Currently, only takes into account the app's templates.
    def all
      Dir[root + "/app/views/**/*.erb"]
    end

    private

    def store
      @store ||= {}
    end

    def root
      @root ||= Rails.root.to_s
    end
  end

  module Ext
    def initialize(*, **)
      super
      TemplatesTracker.track(@identifier)
    end
  end
end

if ENV["TT"]
  TemplatesTracker.start(ENV["TT"])

  RSpec.configure do |config|
    config.after(:suite) do
      TemplatesTracker.print
    end
  end
end
