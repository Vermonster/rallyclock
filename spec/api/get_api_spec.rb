require 'spec_helper'

describe "Read API" do
  def app
    RallyClock::API
  end

  it "passes the sanity test" do
    get '/api/v1/system/pang'
    JSON.parse(last_response.body).should == { "foo" => "SLURM!" }
  end

  describe "Read API" do
      let!(:joe)        { User.create    username: "Joe"    , email: "joe@vermonster.com"   , password: "foo" }
      let!(:brian)      { User.create    username: "Brian"  , email: "brian@vermonster.com" , password: "foo" }
      let!(:vermonster) { Group.create   name: "Vermonster" , owner_id: brian.id }
      let!(:koko)       { Client.create  name: "Koko"       , account: "KOKO" }
      let!(:my_koko)    { Project.create name: "My Koko"    , code: "MYKOKO" }
      let!(:entry)      { Entry.create note: "This better friggin' work", time: 420, project_id: my_koko.id, user_id: joe.id }

    before do
      Membership.create(user_id: brian.id, group_id: vermonster.id)
      Membership.create(user_id: joe.id, group_id: vermonster.id)
      vermonster.add_client koko
      koko.add_project my_koko
    end

    context "Entries" do 
      it "should respond with 404 when you try to get a resource that doesn't exist" do
        get '/api/v1/entries/1000000', {t: joe.api_key}
        last_response.status.should == 404
      end

      it "should respond with 401 when another user tries to look at the resource" do
        get "/api/v1/entries/#{entry.id}", {t: brian.api_key}
        last_response.status.should == 401
      end

      it "should respond with appropriate JSON when you try to get a resource" do
        get "/api/v1/entries/#{entry.id}", {t: joe.api_key}
        last_response.status.should == 200
      end
    end

    context "Group" do 
      it "should respond with 404 when you try to get a resource that doesn't exist" do
        get '/api/v1/groups/1000000', {t: joe.api_key}
        last_response.status.should == 404
      end

      it "should respond with 401 when another user tries to look at the resource" do
        get "/api/v1/groups/#{vermonster.id}", {t: joe.api_key}
        last_response.status.should == 401
      end

      it "should respond with appropriate JSON when you try to get a resource" do
        get "/api/v1/groups/#{vermonster.id}", {t: brian.api_key}
        last_response.status.should == 200
      end
    end

    context "Client" do 
      it "should respond with 404 when you try to get a resource that doesn't exist" do
        get "/api/v1/groups/#{vermonster.id}/clients/1000000", {t: brian.api_key}
        last_response.status.should == 404
      end

      it "should respond with 401 when another user tries to look at the resource" do
        get "/api/v1/groups/#{vermonster.id}/clients/#{koko.account}", {t: joe.api_key}
        last_response.status.should == 401
      end

      it "should respond with appropriate JSON when you try to get a resource" do
        get "/api/v1/groups/#{vermonster.id}/clients/#{koko.account}", {t: brian.api_key}
        last_response.status.should == 200
      end
    end

    context "Projects" do 
      it "should respond with 404 when you try to get a resource that doesn't exist" do
        get "/api/v1/groups/#{vermonster.id}/clients/#{koko.account}/projects/120391", {t: brian.api_key}
        last_response.status.should == 404
      end

      it "should respond with 401 when another user tries to look at the resource" do
        get "/api/v1/groups/#{vermonster.id}/clients/#{koko.account}/projects/#{my_koko.code}", {t: joe.api_key}
        last_response.status.should == 401
      end

      it "should respond with appropriate JSON when you try to get a resource" do
        get "/api/v1/groups/#{vermonster.id}/clients/#{koko.account}/projects/#{my_koko.code}", {t: brian.api_key}
        last_response.status.should == 200
      end
    end

    context "User" do
      it "should respond with 404 when you try to get a resource that doesn't exist" do
        get '/api/v1/users/123002', {t: joe.api_key}
        last_response.status.should == 404
      end

      it "should respond with 401 when another user tries to look at the resource" do
        get "/api/v1/users/Joe", {t: brian.api_key}
        last_response.status.should == 401
      end

      it "should respond with appropriate JSON when you try to get a resource" do
        get "/api/v1/users/Joe", {t: joe.api_key}
        last_response.status.should == 200
      end
    end
  end
end
