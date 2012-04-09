require 'spec_helper'

describe User do
  it { should have_column(:email) }
  #it { should validate_presence_of(:email) }
  it { should restrict_access_to(:password_salt) }
  it { should restrict_access_to(:password_hash) }
  it { should have_one_to_many(:entries) }

  it "is valid when it has a email and password" do
    u = User.new(email: 'a@foo.com', password: 'apples')
    u.should be_valid
  end

  it "generates an api_key after creation" do
    u = User.create(email: 'a@foo.com', password: 'apples')
    u.api_key.should_not be_nil
  end

  it "has authentication and returns the user" do
    u = User.create(email: 'a@foo.com', password: 'apples')
    User.authenticate('a@foo.com','apples').should eq(u)
  end
end
