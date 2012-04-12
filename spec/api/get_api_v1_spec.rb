require 'spec_helper'

describe "Read API" do
  def app
    RallyClock::API
  end

  describe "Read API" do
      let!(:joe)        { User.create(username: "Joe", email: "joe@vermonster.com"   , password: "foo") }
      let!(:brian)      { User.create(username: "Brian", email: "brian@vermonster.com" , password: "foo") }
      let!(:vermonster) { Group.create(name: "Vermonster", owner_id: brian.id) }
      let!(:koko)       { Client.create(name: "Koko", account: "KOKO", group_id: vermonster.id) }
      let!(:my_koko)    { Project.create(name: "My Koko", code: "MYKOKO", client_id: koko.id) }
      let!(:entry)      { Entry.create(note: "It works", time: 420, project_id: my_koko.id, user_id: joe.id) }

    before do
      Membership.create(user_id: brian.id, group_id: vermonster.id)
      Membership.create(user_id: joe.id, group_id: vermonster.id)
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

      context "clients" do
        it "returns all its clients" do
          get "/api/v1/groups/#{vermonster.id}/clients", {t: brian.api_key}
          last_response.status.should eq(200)
          content = JSON.parse(last_response.body)
          content.length.should eq(1)
        end
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

      context "projects" do
        it "returns all its projects" do
          get "/api/v1/groups/#{vermonster.id}/clients/#{koko.account}/projects", {t: brian.api_key}
          last_response.status.should eq(200)
          content = JSON.parse(last_response.body)
          content.length.should eq(1)
        end
      end
    end

    context "Entries" do
      it "responds with appropriate JSON on success when accessing index on group" do
        get "/api/v1/groups/#{vermonster.id}/entries", {t: brian.api_key}
        last_response.status.should eq(200)
        content = JSON.parse(last_response.body)
        content.length.should eq(1)
        content.first['time'].should eq(420)
      end
      
      it "responds with appropriate JSON on success when accessing index on client" do
        get "/api/v1/groups/#{vermonster.id}/clients/#{koko.account}/entries", {t: brian.api_key}
        last_response.status.should eq(200)
        content = JSON.parse(last_response.body)
        content.length.should eq(1)
        content.first['time'].should eq(420)
      end
      
      it "responds with appropriate JSON on success when accessing show on group" do
        get "/api/v1/groups/#{vermonster.id}/entries/#{entry.id}", {t: brian.api_key}
        last_response.status.should eq(200)
        content = JSON.parse(last_response.body)
        content['time'].should eq(420)
      end
      
      it "responds with appropriate JSON on success when accessing show on client" do
        get "/api/v1/groups/#{vermonster.id}/clients/#{koko.account}/entries/#{entry.id}", {t: brian.api_key}
        last_response.status.should eq(200)
        content = JSON.parse(last_response.body)
        content['time'].should eq(420)
      end
      
      it "responds with a 404 if the entry doesn't exist for group" do
        get "/api/v1/groups/#{vermonster.id}/entries/#{entry.id+1}", {t: brian.api_key}
        last_response.status.should eq(404)
      end
      
      it "responds with a 404 if the entry doesn't exist for client" do
        get "/api/v1/groups/#{vermonster.id}/entries/#{entry.id+1}", {t: brian.api_key}
        last_response.status.should eq(404)
      end
      
      it "responds with a 401 when index is accessed by a non-admin on group" do
        get "/api/v1/groups/#{vermonster.id}/entries", {t: joe.api_key}
        last_response.status.should eq(401)
      end
      
      it "responds with a 401 when index is accessed by a non-admin on client" do
        get "/api/v1/groups/#{vermonster.id}/clients/#{koko.account}/entries", {t: joe.api_key}
        last_response.status.should eq(401)
      end
      
      it "responds with a 401 when show is accessed by a non-admin on group" do
        get "/api/v1/groups/#{vermonster.id}/entries/#{entry.id}", {t: joe.api_key}
        last_response.status.should eq(401)
      end
      
      it "responds with a 401 when show is accessed by a non-admin on client" do
        get "/api/v1/groups/#{vermonster.id}/clients/#{koko.account}/entries/#{entry.id}", {t: joe.api_key}
        last_response.status.should eq(401)
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
  end
end
