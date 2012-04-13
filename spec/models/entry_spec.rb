require 'spec_helper'

describe Entry do
  it { should have_column(:time, :type => :integer) }
  it { should have_column(:note, :type => :string) }
  it { should have_column(:date, :type => :date) }
  it { should have_column(:billable, :type => :boolean) }
  it { should have_many_to_one(:user) }

  before do
    u = User.create(email: 'a@foo.com', password: 'apples', username: 'a')
    g = Group.create(name: 'vermonster', handle: 'vermonster', owner_id: u.id)
    c = Client.create(name: 'verm', group_id: g.id, account: 'verm')
    p = Project.create(name: 'rallyclock', client_id: c.id, code: 'r10')
    @e = Entry.create(time: 10, note: 'chunky bacon', user_id: u.id, project_id: p.id)
  end

  it "is valid" do
    @e.should be_valid
  end

  it "has its date default to today" do
    @e.date.should eq(Date.today)
  end

  it "is billable by default" do
    @e.billable.should be_true
  end
end
