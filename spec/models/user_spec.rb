require 'spec_helper'

describe User do
  it { should have_column(:email, :type => :string) }

  #it { should validate_presence_of(:email) }
  #it { should validate_presence_of(:username) }
  #it { should validate_uniqueness_of(:email) }
  #it { should validate_uniqueness_of(:username) }
  
  it { should restrict_access_to(:password_salt) }
  it { should restrict_access_to(:password_hash) }
  it { should have_one_to_many(:entries) }
  it { should have_one_to_many(:memberships) }
  it { should have_many_to_many(:groups) }

  subject { User.create(email: 'a@foo.com', password: 'apples', username: 'a') }
  before { subject.save } 

  it { should be_valid }
  its(:api_key) { should_not be_nil } 

  it "has authentication and returns the user" do
    subject.save
    User.authenticate('a@foo.com','apples').should eq(subject)
  end
end
