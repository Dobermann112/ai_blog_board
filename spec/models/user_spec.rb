require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with a valid email and password" do
    user = User.create!(email: "user@example.com", password: "password")
    expect(user).to be_persisted
  end

  it "is invalid without an email" do
    user = User.new(email: nil, password: "password")
    expect(user).not_to be_valid
  end
end
