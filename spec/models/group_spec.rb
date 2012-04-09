require 'spec_helper'

describe Group do
  it { should have_column(:name, :type => :string) }
  it { should have_one_to_many(:users) }
  it { should have_many_to_one(:owner) }
end
