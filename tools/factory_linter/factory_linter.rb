module FactoryLinter
  # Add @block accessor to attribute
  using(Module.new do
    refine FactoryBot::Attribute do
      attr_reader :block
    end
  end)

  module Utils
    module_function

    # Checks whether the definition uses SecureRandom
    def secure_random?(attr)
      attr.block.source.match?(/SecureRandom\./)
    end

    # Checks whether the attribute definition is
    # an inline sequence definition
    def sequence?(attr)
      return true if attr.is_a?(::FactoryBot::Attribute::Sequence)

      attr.block.source_location.first == sequence_file &&
        sequence_range.include?(attr.block.source_location.last)
    end

    # Get the sequence definition source code
    # https://github.com/thoughtbot/factory_bot/blob/79331a38639874276c99d54793061c280682b8a5/lib/factory_bot/definition_proxy.rb#L119-L123
    def sequence_range
      @sequence_range ||= FactoryBot::DefinitionProxy.instance_method(:sequence).then do |meth|
        # Uses `method_source` to get the source code and the number of lines
        meth.source_location.last..(meth.source_location.last + meth.source.lines.size)
      end
    end

    def sequence_file
      @sequence_file ||= FactoryBot::DefinitionProxy.instance_method(:sequence).source_location.first
    end
  end

  # Check that an attribute has a unique value if it has a uniqueness
  # constraint in the db.
  #
  # Requires an attribute to be defined using a sequence to be 100% sure
  # that it's unique (Faker doesn't guarantee this by default).
  #
  # Allows attributes defined with `SecureRandom`.
  module UniquenessCheck
    module_function

    def unique_columns(model)
      @unique_columns ||= {}

      # Only take into account unique indexes with one column
      @unique_columns[model.table_name] ||= model.connection.indexes(model.table_name).select do |index|
        index.unique && (index.columns.size == 1 || String === index.columns)
      end.map do |index|
        if String === index.columns
          # Try to guess an index column from its name (e.g. index_cities_on_name)
          index.name.match(/index_#{model.table_name}_on_([^_]+)$/).then do |matches|
            next unless matches
            $stdout.puts "\e[37mUsing #{matches[1]} as column for #{model.table_name}##{index.name} (#{index.columns})\e[0m"
            matches[1].to_sym
          end
        else
          index.columns.first.to_sym
        end
      end.compact
    end

    # Takes definition and raises error
    # if attribute has uniqueness validation
    # or unique index and isn't generated via sequence
    def call(factory, errors)
      # check only originals
      return unless factory.send(:parent).is_a?(FactoryBot::NullFactory)

      model = factory.build_class
      return unless model <= ActiveRecord::Base

      unique_columns = unique_columns(model)

      return if unique_columns.empty?

      unique_columns.each do |column|
        defn = factory.definition.attributes.find { |attr| attr.name == column }
        next if defn.nil?
        next if Utils.sequence?(defn)
        next if Utils.secure_random?(defn)

        errors << "Factory #{factory.name} should use a sequence for :#{column} attribute, " \
                  "'cause it has a uniqueness constraint"
      end
    end
  end

  def self.call
    errors = []

    checks = [UniquenessCheck]

    FactoryBot.factories.each do |factory|
      checks.each { |check| check.call(factory, errors) }
    end

    if errors.empty?
      $stdout.puts "\e[32mAll is OK\e[0m"
    else
      $stdout.puts "\e[31m\nFactory lint detected the following errors:\n\n"
      $stdout.puts errors.join("\n")
      $stdout.puts "\e[0m"
      exit(1)
    end
  end
end
