require "rails_helper"

RSpec.describe ApplicationMailer do
  it "inherits from ActionMailer::Base" do
    expect(described_class.ancestors).to include(ActionMailer::Base)
  end
end
