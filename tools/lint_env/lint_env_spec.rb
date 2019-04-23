require "spec_helper"
require "common/rubocop/cop/lint_env"

describe RuboCop::Cop::Lint::Env, :config do
  subject(:cop) { described_class.new(config) }

  it "rejects ENV usage" do
    inspect_source("a = ENV['x']")
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages.first).to include("Avoid direct usage of ENV in application code")
  end

  it "rejects ::ENV usage" do
    inspect_source("a = ::ENV['x']")
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages.first).to include("Avoid direct usage of ENV in application code")
  end

  it "rejects Rails.env usage" do
    inspect_source("a = Rails.env.production?")
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages.first).to include("Avoid direct usage of Rails.env in application code")
  end

  it "reject Rails.env with condition" do
    inspect_source(<<~SOURCE
      if Rails.env.production?
        true
      end
    SOURCE
                  )
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages.first).to include("Avoid direct usage of Rails.env in application code")
  end

  it "accepts nested constant" do
    inspect_source("a = Custom::ENV")
    expect(cop.offenses).to be_empty
  end

  it "accepts nested constant with dot" do
    inspect_source("a = Custom.ENV")
    expect(cop.offenses).to be_empty
  end

  it "accepts other Rails.x methods" do
    inspect_source("a = Rails.envy")
    expect(cop.offenses).to be_empty
  end
end