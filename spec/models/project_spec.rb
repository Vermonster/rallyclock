require 'spec_helper'

describe Project do
  it { should have_column(:name, :type => :string) }
  it { should have_column(:description, :type => :string) }
  it { should have_column(:active, :type => :boolean) }
  it { should have_column(:billable, :type => :boolean) }
  it { should have_column(:code, :type => :string) }
  it { should have_many_to_one(:client) }
end
