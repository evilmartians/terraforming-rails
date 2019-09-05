# Warn if Timecop hasn't been returned at the end of the top-level example group.
module TimecopLinter
  class Listener # :nodoc:
    NOTIFICATIONS = %i[
      example_group_finished
    ].freeze

    def example_group_finished(notification)
      return unless notification.group.top_level?

      if Timecop.frozen?
        TestProf.log(
          :warn,
          "📛 ⏰ 📛 Timecop hasn't returned at the end of the test file!\n" \
          "File: #{notification.group.metadata[:location]}\n"
        )
      end
    end
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    listener = TimecopLinter::Listener.new

    config.reporter.register_listener(
      listener, *TimecopLinter::Listener::NOTIFICATIONS
    )
  end
end
