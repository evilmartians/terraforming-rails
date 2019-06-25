# frozen_string_literal: true

# Check for changes in credentials
creds_files_regexp = /config\/credentials\//

modified_creds_files = CHANGED_FILES.select { |path| path =~ creds_files_regexp }

if modified_creds_files.any?
  message "🔑 This PR changes credentials: #{github.html_link(modified_creds_files)}\n" \
          "Please, describe changes in the PR description"
end
