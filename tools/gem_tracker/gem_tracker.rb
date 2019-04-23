# frozen_string_literal: true

require "memory_profiler"
require "set"

# Tracks gems that are used by the application.
# 
# Compares this set with the gems specified in Gemfile and
# report which gems haven't left any trace during the execution.
class GemTracker
  # Based on https://github.com/SamSaffron/memory_profiler/blob/master/lib/memory_profiler/reporter.rb
  module ObjectAllocation
    module_function

    def start
      # Die young
      3.times { GC.start }
      GC.disable

      @generation = GC.count

      ObjectSpace.trace_object_allocations_start
    end

    def collect(gems:)
      ObjectSpace.trace_object_allocations_stop

      ObjectSpace.each_object do |obj|
        next unless ObjectSpace.allocation_generation(obj) == @generation

        file = ObjectSpace.allocation_sourcefile(obj)

        next unless file

        gem = GemTracker.helper.guess_gem(file)

        next unless gem

        gems << gem
      end

      gems
    end
  end

  # Using TracePoint API https://ruby-doc.org/core-2.6/TracePoint.html
  #
  # NOTE: This approach is much slower.
  module TP
    module_function

    def start
      @gems = Set.new
      tp.enable
    end

    def collect(gems:)
      tp.disable

      @gems.each { |gem| gems << gem }
    end

    def tp
      TracePoint.trace(:call) do |tp|
        name = GemTracker.helper.guess_gem(tp.path)
        @gems << name if name
      end
    end
  end

  class << self
    attr_reader :instance

    delegate :report_unused, :stop, :start, :flush, :maybe_flush, to: :instance

    def start
      collector = ENV["GEM_TRACK"] == "tp" ? TP : ObjectAllocation
      @instance = new(collector)
      instance.start
    end

    def helper
      @helper ||= MemoryProfiler::Helpers.new
    end
  end

  attr_reader :collector, :gems, :deps

  def initialize(collector)
    @gems = Set.new
    @deps = build_deps
    @collector = collector
  end

  def start
    collector.start
  end

  def maybe_flush
    return if rand > 0.4
    flush
  end

  def flush
    stop
    report_unused(false)
    start
  end

  def stop
    collector.collect(gems: gems)
  end

  def report_unused(print_list = true)
    maybe_unused = deps.each_with_object([]) do |name, acc|
      acc << name unless gems.include?(name)
    end

    if print_list
      $stdout.puts "\e[33m\nMaybe unused gems:\n\n"
      $stdout.puts maybe_unused.sort.join("\n")
      $stdout.puts "\e[0m"
    end
    $stdout.puts "\e[33mTotal maybe unused gems: #{maybe_unused.size} (of #{deps.size})\e[0m"
  end

  def build_deps
    groups = Rails.groups.map(&:to_sym)

    Bundler.setup.dependencies.select do |dep|
      # Only take into account current env
      !(dep.groups & groups).empty?
    end.map do |dep|
      loaded_spec = Gem.loaded_specs[dep.name]
      # skip local gems (loaded from path)
      next unless loaded_spec.is_a?(Bundler::RemoteSpecification)

      # we need to known the actual load path for the gem (to handle non-RubyGems sources, e.g. Git)
      Regexp.last_match[1] if loaded_spec.load_paths.first =~ /\/gems\/([^\/]+)\/lib$/
    end.compact
  end
end

if ENV["GEM_TRACK"]
  RSpec.configure do |config|
    config.before(:suite) do
      GemTracker.start
    end

    config.after(:all) do
      # flush object space to avoid high memory usage
      GemTracker.maybe_flush
    end

    # Cleanup files
    config.after(:suite) do
      GemTracker.stop

      GemTracker.report_unused
    end
  end
end
