require 'spec_helper'

describe Project do
  it { should have_column(:name, :type => :string) }
  it { should have_column(:description, :type => :string) }
  it { should have_column(:active, :type => :boolean) }
  it { should have_column(:billable, :type => :boolean) }
  it { should have_column(:code, :type => :string) }
  it { should have_many_to_one(:client) }

  before do
    u = User.create(email: 'a@foo.com', password: 'apples', username: 'a')
    g = Group.create(name: 'vermonster', owner_id: u.id)
    c = Client.create(name: 'verm', group_id: g.id, account: 'verm')
    @p = Project.create(name: 'rallyclock', client_id: c.id, code: 'r10')
  end

  it "is active by default" do
    @p.active.should be_true
  end

  it "is billable by default" do
    @p.billable.should be_true
  end
end
