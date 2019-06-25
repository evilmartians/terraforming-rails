# frozen_string_literal: true

# Check that there are both app and test code changes for the main app
changed_app_files = CHANGED_FILES.select { |path| path =~ /^(app|config)/ }

if changed_app_files.any?
  changed_test_files = CHANGED_FILES.select { |path| path =~ /^spec/ }

  if changed_test_files.empty?
    warn "Are you sure we don't need to add/update tests for the main app?"
  end
end
