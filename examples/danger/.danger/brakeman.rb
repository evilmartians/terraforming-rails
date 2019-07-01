# frozen_string_literal: true

require "brakeman"

tracker = Brakeman.run(
  app_path: File.join(__dir__, "../"),
  ignore_file: File.join(__dir__, "brakeman.ignore")
)

if tracker.errors.any? || tracker.filtered_warnings.any?
  tracker.options[:output_formats] = [:to_html]
  Brakeman.send(:write_report_to_files, tracker, ["tmp/brakeman/report.html"])

  warn "Brakeman failed!\n"\
       "Errors: #{tracker.errors.count}.\n" \
       "Warnings: #{tracker.filtered_warnings.count}\n" \
       "See #{artefacts_link("report")}."
end

# check whether brakeman ignore config has been changed
ignore_updated = CHANGED_FILES.include?(".danger/brakeman.ignore")

if ignore_updated
  warn "Brakeman ignore config has been updated.\n" \
       "Don't forget to tell about this change in the PR description"
end
