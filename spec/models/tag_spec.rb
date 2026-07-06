require "rails_helper"

RSpec.describe Tag, type: :model do
  it "is valid with a unique name" do
    tag = Tag.new(name: "Ruby")
    expect(tag).to be_valid
  end

  it "is invalid without a name" do
    tag = Tag.new(name: nil)
    expect(tag).not_to be_valid
  end

  it "is invalid with a duplicate name" do
    Tag.create!(name: "Ruby")
    tag = Tag.new(name: "Ruby")
    expect(tag).not_to be_valid
  end
end
