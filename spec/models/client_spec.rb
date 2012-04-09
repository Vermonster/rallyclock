require 'spec_helper'

describe Client do
  it { should have_one_to_many(:projects) }
  it { should have_many_to_one(:group) }
  it { should have_column(:name, :type => :string) }
  it { should have_column(:active, :type => :boolean) }
  it { should have_column(:description, :type => :string) }
  it { should have_column(:account, :type => :string) }
end
