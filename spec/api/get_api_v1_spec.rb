require 'spec_helper'

describe "Read API" do
  def app
    RallyClock::API
  end

  describe "Read API" do
      let!(:joe)        { User.create(username: "Joe", email: "joe@vermonster.com"   , password: "foo") }
      let!(:brian)      { User.create(username: "Brian", email: "brian@vermonster.com" , password: "foo") }
      let!(:vermonster) { Group.create(name: "Vermonster", handle: 'vermonster', owner_id: brian.id) }
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
        get "/api/v1/#{vermonster.handle}", {t: joe.api_key}
        last_response.status.should == 401
      end

      it "should respond with appropriate JSON when you try to get a resource" do
        get "/api/v1/#{vermonster.handle}", {t: brian.api_key}
        last_response.status.should == 200
      end

      context "Group Clients" do
        it "returns all its clients" do
          get "/api/v1/#{vermonster.handle}/clients", {t: brian.api_key}
          last_response.status.should eq(200)
          content = JSON.parse(last_response.body)
          content.length.should eq(1)
        end
      end

      context "Group Users" do
        it "returns all its users" do
          get "/api/v1/#{vermonster.handle}/users", {t: brian.api_key}
          last_response.status.should eq(200)
          content = JSON.parse(last_response.body)
          content.length.should eq(2)
        end

        it "returns the given user" do
          get "/api/v1/#{vermonster.handle}/users/#{brian.username}", {t: brian.api_key}
          last_response.status.should eq(200)
          content = JSON.parse(last_response.body)
          content['username'].should eq("Brian")
        end
      end
    end

    context "Client" do 
      it "should respond with 404 when you try to get a resource that doesn't exist" do
        get "/api/v1/#{vermonster.handle}/clients/1000000", {t: brian.api_key}
        last_response.status.should == 404
      end

      it "should respond with 401 when another user tries to look at the resource" do
        get "/api/v1/#{vermonster.handle}/clients/#{koko.account}", {t: joe.api_key}
        last_response.status.should == 401
      end

      it "should respond with appropriate JSON when you try to get a resource" do
        get "/api/v1/#{vermonster.handle}/clients/#{koko.account}", {t: brian.api_key}
        last_response.status.should == 200
      end

      context "projects" do
        it "returns all its projects" do
          get "/api/v1/#{vermonster.handle}/clients/#{koko.account}/projects", {t: brian.api_key}
          last_response.status.should eq(200)
          content = JSON.parse(last_response.body)
          content.length.should eq(1)
        end
      end
    end

    context "Entries" do
      it "responds with appropriate JSON on success when accessing index on group" do
        get "/api/v1/#{vermonster.handle}/entries", {t: brian.api_key}
        last_response.status.should eq(200)
        content = JSON.parse(last_response.body)
        content.length.should eq(1)
        content.first['time'].should eq(420)
      end
      
      it "responds with appropriate JSON on success when accessing index on users" do
        get "/api/v1/#{vermonster.handle}/users/#{joe.username}/entries", {t: brian.api_key}
        last_response.status.should eq(200)
        content = JSON.parse(last_response.body)
        content.length.should eq(1)
        content.first['time'].should eq(420)
      end
      
      it "responds with appropriate JSON on success when accessing index on client" do
        get "/api/v1/#{vermonster.handle}/clients/#{koko.account}/entries", {t: brian.api_key}
        last_response.status.should eq(200)
        content = JSON.parse(last_response.body)
        content.length.should eq(1)
        content.first['time'].should eq(420)
      end
      
      it "responds with appropriate JSON on success when accessing show on group" do
        get "/api/v1/#{vermonster.handle}/entries/#{entry.id}", {t: brian.api_key}
        last_response.status.should eq(200)
        content = JSON.parse(last_response.body)
        content['time'].should eq(420)
      end
      
      it "responds with appropriate JSON on success when accessing show on client" do
        get "/api/v1/#{vermonster.handle}/clients/#{koko.account}/entries/#{entry.id}", {t: brian.api_key}
        last_response.status.should eq(200)
        content = JSON.parse(last_response.body)
        content['time'].should eq(420)
      end
      
      it "responds with a 404 if the entry doesn't exist for group" do
        get "/api/v1/#{vermonster.handle}/entries/#{entry.id+1}", {t: brian.api_key}
        last_response.status.should eq(404)
      end
      
      it "responds with a 404 if the entry doesn't exist for client" do
        get "/api/v1/#{vermonster.handle}/entries/#{entry.id+1}", {t: brian.api_key}
        last_response.status.should eq(404)
      end
      
      it "responds with a 401 when index is accessed by a non-admin on group" do
        get "/api/v1/#{vermonster.handle}/entries", {t: joe.api_key}
        last_response.status.should eq(401)
      end
      
      it "responds with a 401 when index is accessed by a non-admin on client" do
        get "/api/v1/#{vermonster.handle}/clients/#{koko.account}/entries", {t: joe.api_key}
        last_response.status.should eq(401)
      end
      
      it "responds with a 401 when show is accessed by a non-admin on group" do
        get "/api/v1/#{vermonster.handle}/entries/#{entry.id}", {t: joe.api_key}
        last_response.status.should eq(401)
      end
      
      it "responds with a 401 when show is accessed by a non-admin on client" do
        get "/api/v1/#{vermonster.handle}/clients/#{koko.account}/entries/#{entry.id}", {t: joe.api_key}
        last_response.status.should eq(401)
      end
      
      describe "GET /api/v1/:handle/users/entries?from=YYYYMMDD&to=YYYYMMDD" do
        before do
          Entry.create(note: 'entry #3', time: 10, date: '2011-12-31', project_id: my_koko.id, user_id: joe.id) 
          Entry.create(note: 'entry #4', time: 10, date: '2012-01-01', project_id: my_koko.id, user_id: joe.id) 
          Entry.create(note: 'entry #5', time: 10, date: '2012-02-01', project_id: my_koko.id, user_id: joe.id) 
          Entry.create(note: 'entry #2', time: 10, date: '2012-03-01', project_id: my_koko.id, user_id: joe.id) 
          
          # entries available by date
          # 1. Today (It works)
          # 2. 2012-03-01
          # 5. 2012-02-01
          # 4. 2012-01-01
          # 3. 2011-12-31
        end

        it "returns the correct entries using from" do
          get "/api/v1/#{vermonster.handle}/users/#{joe.username}/entries?from=20120201", { t: brian.api_key }
          last_response.status.should eq(200)

          content = JSON.parse(last_response.body)
          content.length.should eq(3)
        end
        
        it "returns the correct entries using to" do
          get "/api/v1/#{vermonster.handle}/users/#{joe.username}/entries?to=20120131", { t: brian.api_key }
          last_response.status.should eq(200)

          content = JSON.parse(last_response.body)
          content.length.should eq(2)
        end
        
        it "returns the correct entries using from and to" do
          get "/api/v1/#{vermonster.handle}/users/#{joe.username}/entries?from=20120101&to=20120201", { t: brian.api_key }
          last_response.status.should eq(200)

          content = JSON.parse(last_response.body)
          content.length.should eq(2)
        end
      end
      
      describe "GET /api/v1/:handle/clients/entries?from=YYYYMMDD&to=YYYYMMDD" do
        before do
          Entry.create(note: 'entry #3', time: 10, date: '2011-12-31', project_id: my_koko.id, user_id: joe.id) 
          Entry.create(note: 'entry #4', time: 10, date: '2012-01-01', project_id: my_koko.id, user_id: joe.id) 
          Entry.create(note: 'entry #5', time: 10, date: '2012-02-01', project_id: my_koko.id, user_id: joe.id) 
          Entry.create(note: 'entry #2', time: 10, date: '2012-03-01', project_id: my_koko.id, user_id: joe.id) 
          
          # entries available by date
          # 1. Today (It works)
          # 2. 2012-03-01
          # 5. 2012-02-01
          # 4. 2012-01-01
          # 3. 2011-12-31
        end

        it "returns the correct entries using from" do
          get "/api/v1/#{vermonster.handle}/clients/#{koko.account}/entries?from=20120201", { t: brian.api_key }
          last_response.status.should eq(200)

          content = JSON.parse(last_response.body)
          content.length.should eq(3)
        end
        
        it "returns the correct entries using to" do
          get "/api/v1/#{vermonster.handle}/clients/#{koko.account}/entries?to=20120131", { t: brian.api_key }
          last_response.status.should eq(200)

          content = JSON.parse(last_response.body)
          content.length.should eq(2)
        end
        
        it "returns the correct entries using from and to" do
          get "/api/v1/#{vermonster.handle}/clients/#{koko.account}/entries?from=20120101&to=20120201", { t: brian.api_key }
          last_response.status.should eq(200)

          content = JSON.parse(last_response.body)
          content.length.should eq(2)
        end
      end
      
      describe "GET /api/v1/:handle/projects/:code/entries?from=YYYYMMDD&to=YYYYMMDD" do
        before do
          Entry.create(note: 'entry #3', time: 10, date: '2011-12-31', project_id: my_koko.id, user_id: joe.id) 
          Entry.create(note: 'entry #4', time: 10, date: '2012-01-01', project_id: my_koko.id, user_id: joe.id) 
          Entry.create(note: 'entry #5', time: 10, date: '2012-02-01', project_id: my_koko.id, user_id: joe.id) 
          Entry.create(note: 'entry #2', time: 10, date: '2012-03-01', project_id: my_koko.id, user_id: joe.id) 
          
          # entries available by date
          # 1. Today (It works)
          # 2. 2012-03-01
          # 5. 2012-02-01
          # 4. 2012-01-01
          # 3. 2011-12-31
        end

        it "returns the correct entries using from" do
          get "/api/v1/#{vermonster.handle}/projects/#{my_koko.code}/entries?from=20120201", { t: brian.api_key }
          last_response.status.should eq(200)

          content = JSON.parse(last_response.body)
          content.length.should eq(3)
        end
        
        it "returns the correct entries using to" do
          get "/api/v1/#{vermonster.handle}/projects/#{my_koko.code}/entries?to=20120131", { t: brian.api_key }
          last_response.status.should eq(200)

          content = JSON.parse(last_response.body)
          content.length.should eq(2)
        end
        
        it "returns the correct entries using from and to" do
          get "/api/v1/#{vermonster.handle}/projects/#{my_koko.code}/entries?from=20120101&to=20120201", { t: brian.api_key }
          last_response.status.should eq(200)

          content = JSON.parse(last_response.body)
          content.length.should eq(2)
        end
      end
    end

    context "Projects" do 
      it "should respond with 404 when you try to get a resource that doesn't exist" do
        get "/api/v1/#{vermonster.handle}/clients/#{koko.account}/projects/120391", {t: brian.api_key}
        last_response.status.should == 404
      end

      it "should respond with 401 when another user tries to look at the resource" do
        get "/api/v1/#{vermonster.handle}/clients/#{koko.account}/projects/#{my_koko.code}", {t: joe.api_key}
        last_response.status.should == 401
      end

      it "should respond with appropriate JSON when you try to get a resource" do
        get "/api/v1/#{vermonster.handle}/clients/#{koko.account}/projects/#{my_koko.code}", {t: brian.api_key}
        last_response.status.should == 200
      end
    end
  end
end
