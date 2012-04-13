require 'spec_helper'

describe "Me" do
  def app
    RallyClock::API
  end

  let!(:brian) { User.create(username: 'bkaney', email: 'bkaney@vermonster.com', password: 'foo') }
  let!(:me) { User.create(username: 'tx', email: 'tx@gmail.com', password: 'foo') }
  let!(:token) { me.api_key }
  let!(:vermonster) { Group.create(name: 'Vermonster', handle: 'vermonster', owner_id: brian.id) }
  let!(:mem) { Membership.create(user_id: me.id, group_id: vermonster.id) }
  let!(:toy) { Client.create(name: 'toy', account: 'toy', group_id: vermonster.id) }
  let!(:proj) { Project.create(name: 'proj', code: 'proj', client_id: toy.id) }
  let!(:e1) { Entry.create(note: 'entry #1', time: 10, project_id: proj.id, user_id: me.id) } 
  let!(:e2) { Entry.create(note: 'entry #2', time: 15, date: '2012-03-01', project_id: proj.id, user_id: me.id) }

  describe "GET /me" do
    it "returns information about myself" do
      get "/api/v1/me", { t: token }
      last_response.status.should eq(200)
      content = JSON.parse(last_response.body)
      content['username'].should eq('tx')
    end
  end

  context "Projects" do
    describe "GET /me/projects" do
      it "returns my projects" do
        get "/api/v1/me/projects", { t: token }
        last_response.status.should eq(200)

        content = JSON.parse(last_response.body)
        content.length.should eq(1)
        content.first['code'].should eq('proj')
      end
    end
  end

  context "Entries" do
    describe "GET /me/entries" do
      it "returns my entries" do
        get "/api/v1/me/entries", { t: token }
        last_response.status.should eq(200)

        content = JSON.parse(last_response.body)
        content.length.should eq(2)
      end
    end

    describe "GET /me/entries/:id" do
      it "returns the given entry" do
        get "/api/v1/me/entries/#{e1.id}", { t: token }
        last_response.status.should eq(200)

        content = JSON.parse(last_response.body)
        content['note'].should eq('entry #1')
      end
    end
    
    describe "GET /me/entries?from=YYYYMMDD&to=YYYYMMDD" do
      before do
        Entry.create(note: 'entry #3', time: 10, date: '2011-12-31', project_id: proj.id, user_id: me.id) 
        Entry.create(note: 'entry #4', time: 10, date: '2012-01-01', project_id: proj.id, user_id: me.id) 
        Entry.create(note: 'entry #5', time: 10, date: '2012-02-01', project_id: proj.id, user_id: me.id) 
        
        # entries available by date
        # 1. Today
        # 2. 2012-03-01
        # 3. 2012-02-01
        # 4. 2012-01-01
        # 5. 2011-12-31
      end

      it "returns the correct entries using from" do
        get "/api/v1/me/entries?from=20120201", { t: token }
        last_response.status.should eq(200)

        content = JSON.parse(last_response.body)
        content.length.should eq(3)
      end
      
      it "returns the correct entries using to" do
        get "/api/v1/me/entries?to=20120131", { t: token }
        last_response.status.should eq(200)

        content = JSON.parse(last_response.body)
        content.length.should eq(2)
      end
      
      it "returns the correct entries using from and to" do
        get "/api/v1/me/entries?from=20120101&to=20120201", { t: token }
        last_response.status.should eq(200)

        content = JSON.parse(last_response.body)
        content.length.should eq(2)
      end
    end
  end
end
