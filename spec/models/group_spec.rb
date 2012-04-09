require 'spec_helper'

describe Group do
  it { should have_column(:name, :type => :string) }
  it { should have_many_to_many(:users) }
  it { should have_many_to_one(:owner) }

  let(:owner)   { User.create(email: "o@foo.com", password: "oranges", username: "Lionel") }
  subject { Group.create(owner_id: owner.id, name: "The Commodore 64s") } 

  let(:admin)   { User.create(email: "a@foo.com", password: "oranges", username: "a") }
  let!(:member) { User.create(email: "m@foo.com", password: "oranges", username: "m") }

  before do
    Membership.create(group_id: subject.id, user_id: admin.id, admin: true)
    Membership.create(group_id: subject.id, user_id: member.id, admin: false)
  end


  its(:admins) { should include(admin) } 
  its(:admins) { should include(owner) } 
  its(:admins) { should_not include(member) } 

end
