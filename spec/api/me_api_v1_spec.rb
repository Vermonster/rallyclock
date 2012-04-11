require 'spec_helper'

describe "Me" do
  def app
    RallyClock::API
  end

  let!(:brian) { User.create(username: 'bkaney', email: 'bkaney@vermonster.com', password: 'foo') }
  let!(:me) { User.create(username: 'tx', email: 'tx@gmail.com', password: 'foo') }
  let!(:token) { me.api_key }
  let!(:vermonster) { Group.create(name: 'Vermonster', owner_id: brian.id) }
  let!(:mem) { Membership.create(user_id: me.id, group_id: vermonster.id) }
  let!(:toy) { Client.create(name: 'toy', account: 'toy', group_id: vermonster.id) }
  let!(:proj) { Project.create(name: 'proj', code: 'proj', client_id: toy.id) }
  let!(:e1) { Entry.create(note: 'chunky bacon.', time: 10, project_id: proj.id, user_id: me.id) } 
  let!(:e2) { Entry.create(note: 'wax on. wax off.', time: 15, project_id: proj.id, user_id: me.id) }

  describe "GET /me" do
    it "returns information about myself" do
      get "/api/v1/me", { t: token }
      last_response.status.should eq(200)
      content = JSON.parse(last_response.body)
      content['username'].should eq('tx')
    end
  end

  describe "GET /me/projects" do
    it "returns my projects" do
      get "/api/v1/me/projects", { t: token }
      last_response.status.should eq(200)

      content = JSON.parse(last_response.body)
      content.length.should eq(1)
      content.first['code'].should eq('proj')
    end
  end

  describe "GET /me/entries" do
    it "returns my entries" do
      get "/api/v1/me/entries", { t: token }
      last_response.status.should eq(200)

      content = JSON.parse(last_response.body)
      content.length.should eq(2)
    end
  end
end
