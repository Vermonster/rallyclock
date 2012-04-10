require 'spec_helper'

describe "Read API" do
  def app
    RallyClock::API
  end

  it "passes the sanity test" do
    get '/api/v1/system/pang'
    JSON.parse(last_response.body).should == { "foo" => "SLURM!" }
  end
end
