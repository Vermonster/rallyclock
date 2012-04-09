require 'spec_helper'

describe Membership do
  it { should have_many_to_one(:user) }
  it { should have_many_to_one(:group) }
  it { should have_column(:admin, :type => :boolean) }
  it { should have_column(:client, :type => :boolean) }
  it { should have_column(:owner, :type => :boolean) }
end
