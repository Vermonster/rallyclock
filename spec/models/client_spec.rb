require 'spec_helper'

describe Client do
  it { should have_one_to_many(:projects) }
  it { should have_many_to_one(:group) }
  it { should have_column(:name, :type => :string) }
  it { should have_column(:active, :type => :boolean) }
  it { should have_column(:description, :type => :string) }
  it { should have_column(:account, :type => :string) }

  before do
    u = User.create(email: 'a@foo.com', password: 'apples', username: 'a')
    g = Group.create(name: 'vermonster', owner_id: u.id)
    @c = Client.create(name: 'verm', group_id: g.id, account: 'verm')
  end

  it "is active by default" do
    @c.active.should be_true
  end
end
