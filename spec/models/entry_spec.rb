require 'spec_helper'

describe Entry do
  it { should have_column(:time, :type => :integer) }
  it { should have_column(:note, :type => :string) }
  it { should have_column(:billable, :type => :boolean) }
  it { should have_many_to_one(:user) }

  it "is valid when it has a time, belongs to a user, and has a note" do
    u = User.create(email: 'a@foo.com', password: 'apples')
    e = Entry.create(time: 10, note: 'chunky bacon', user_id: u.id)
    e.should be_valid
  end
end
