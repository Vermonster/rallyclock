require 'spec_helper'

describe RallyClock::API do
  include Rack::Test::Methods

  def app
    RallyClock::API
  end
    
  context "v1" do
    context "system" do
      it "ping" do
        get "/api/v1/system/ping"
        last_response.body.should eq("pong")
      end
    end

    context "POST /users" do
      it "creates a user" do
        expect do
          post "/api/v1/users", { email: 'a@foo.com', password: 'apples', username: 'a' }
        end.to change { User.count }.from(0).to(1)
        last_response.status.should eq(201)

        User.first(email: 'a@foo.com').should_not be_nil
      end

      #it "returns errors if they exist" do
        #post "/api/v1/users"
        #last_response.status.should eq(400)

        #content = JSON.parse(last_response.body)
        #binding.pry
      #end
    end

    context "POST /sessions" do
      it "authenticates a user by X_HEADERS with email" do
        u = User.create(email: 'a@foo.com', password: 'apples', username: 'a')  
      
        post "/api/v1/sessions", {}, { 'HTTP_X_USERNAME' => 'a@foo.com', 'HTTP_X_PASSWORD' => 'apples' } 
        last_response.status.should eq(201)

        content = JSON.parse(last_response.body)
        content.should eq(u)
      end

      it "authenticates a user by X_HEADERS with username" do
        u = User.create(email: 'a@foo.com', password: 'apples', username: 'a')  
      
        post "/api/v1/sessions", {}, { 'HTTP_X_USERNAME' => 'a', 'HTTP_X_PASSWORD' => 'apples' } 
        last_response.status.should eq(201)

        content = JSON.parse(last_response.body)
        content.should eq(u)
      end

      it "authenticates a user by API_KEY" do
        u = User.create(email: 'a@foo.com', password: 'apples', username: 'a')
        token = u.api_key

        post "/api/v1/sessions", {t: token}
        last_response.status.should eq(201)
        
        content = JSON.parse(last_response.body)
        content.should eq(u)
      end
    end

    context "POST /groups" do
      it "creates a new group" do
        u = User.create(email: 'a@foo.com', password: 'apples', username: 'a')
        token = u.api_key
        
        post "/api/v1/groups", {name: 'vermonster', t: token}
        last_response.status.should eq(201)

        u.groups.length.should eq(1)
        u.memberships.length.should eq(1)
        u.memberships.first.group.should == u.groups.first
      end
    end
    
    context "DELETE /groups/:id" do
      let!(:u) { User.create(email: 'a@foo.com', password: 'apples', username: 'a') } 
      let!(:g) { Group.create(name: 'vermonster', owner_id: u.id) } 
      let!(:bono) { User.create(email: 'b@foo.com', password: 'apples', username: 'bono') } 

      before { Membership.create(user_id: u.id, group_id: g.id) } 

      it "deletes a group" do
        delete "/api/v1/groups/#{g.id}", {t: u.api_key}
        last_response.status.should eq(200)
        u.groups.should be_empty
        u.memberships.should be_empty
      end

      it "returns 401 when trying to delete a unowned group" do
        delete "/api/v1/groups/#{g.id}", {t: bono.api_key}
        last_response.status.should eq(401)
        Group.count.should eq(1)
      end
    end

    context "POST /groups/:id/users" do
      let!(:u) { User.create(email: 'a@foo.com', password: 'apples', username: 'a') } 
      let!(:g) { Group.create(name: 'vermonster', owner_id: u.id) } 
      let!(:bono) { User.create(email: 'b@foo.com', password: 'apples', username: 'bono') } 

      before { 
        Membership.create(user_id: u.id, group_id: g.id, admin: true, owner: true) 
      } 

      it "adds a user to the group" do
        post "/api/v1/groups/#{g.id}/users", {email: bono.email, t: u.api_key}
        last_response.status.should eq(201)

        g.users.should include(u,bono)
      end

      it "returns 404 if the user doesn't exist" do
        token = u.api_key

        post "/api/v1/groups/#{g.id}/users", {email: 'c@foo.com', t: token}
        last_response.status.should eq(404)
      end

      it "returns 401 if the user is not an admin" do
        token = bono.api_key

        post "/api/v1/groups/#{g.id}/users", {email: 'c@foo.com', t: token}
        last_response.status.should eq(401)
      end
    end

    context "PUT /groups/:group_id/users/:username" do
      let!(:u) { User.create(email: 'a@foo.com', password: 'apples', username: 'a') } 
      let!(:g) { Group.create(name: 'vermonster', owner_id: u.id) } 
      let!(:bono) { User.create(email: 'b@foo.com', password: 'apples', username: 'bono') } 
      
      before { 
        Membership.create(user_id: u.id, group_id: g.id, admin: true, owner: true) 
      } 

      it "updates an existing user" do
        put "/api/v1/groups/#{g.id}/users/#{bono.username}", { :user => { admin: true }, t: u.api_key } 
        last_response.status.should eq(200)
        bono.should be_admin_of g
      end
      
      it "returns 404 if the user doesn't exist" do
        put "/api/v1/groups/#{g.id}/users/asldfkalsjdhflkajsdhfalskjdfhaskdjfh", { :user => { admin: true }, t: u.api_key }
        last_response.status.should eq(404)
      end
      
      it "returns 401 if the user is not an admin" do
        put "/api/v1/groups/#{g.id}/users/#{u.username}", { :user => { admin: true }, t: bono.api_key }
        last_response.status.should eq(401)
      end
    end
  end
end

