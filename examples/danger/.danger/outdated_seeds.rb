# frozen_string_literal: true

seeds_updated = CHANGED_FILES.select { |path| path =~ /db\/seeds/ }

# Check that the db/seeds.rb file is up to date when new models are added
added_model_files = ADDED_FILES.select { |path| path =~ /app\/models\/(?!concerns)(?!ext)/ }

if added_model_files.any? && !seeds_updated.any?
  warn "Please, check whether you need to update the db/seeds.rb.\n" \
       "You have the following models added:\n" \
       "#{github.html_link(added_model_files)}"
end
