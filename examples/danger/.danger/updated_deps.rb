# frozen_string_literal: true

# Check for changes in dependencies
deps_files_regexp = /Gemfile(?:\.lock)?|package\.json|yarn\.lock|\.gemspec/

modified_deps_files = CHANGED_FILES.select { |path| path =~ deps_files_regexp }

if modified_deps_files.any?
  message "This PR changes #{github.html_link(modified_deps_files)}"
end
