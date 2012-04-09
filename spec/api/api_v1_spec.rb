require 'spec_helper'

describe RallyClock::API do
  include Rack::Test::Methods

  def app
    RallyClock::API
  end

  context "v1" do
    let!(:u) { User.create(email: 'a@foo.com', password: 'apples', username: 'a') } 
    let!(:g) { Group.create(name: 'vermonster', owner_id: u.id) } 
    let!(:bono) { User.create(email: 'b@foo.com', password: 'apples', username: 'bono') } 

    before { Membership.create(user_id: u.id, group_id: g.id, admin: true) } 

    context "system" do
      it "ping" do
        get "/api/v1/system/ping"
        last_response.body.should eq("pong")
      end
    end

    describe "users" do
      context "POST /users" do
        it "creates a user" do
          expect do
            post "/api/v1/users", { email: 'asdlfkj@foo.com', password: 'apples', username: 'sdfkljsd' }
          end.to change { User.count }.from(2).to(3)
          last_response.status.should eq(201)

          User.first(email: u.email).should_not be_nil
        end

        it "returns 401 if the Username or Email has been taken" do
          pending
        end
      end
    end

    describe "sessions" do
      context "POST /sessions" do
        it "authenticates a user by X_HEADERS with email" do
          post "/api/v1/sessions", {}, { 'HTTP_X_USERNAME' => 'a@foo.com', 'HTTP_X_PASSWORD' => 'apples' } 
          last_response.status.should eq(201)

          content = JSON.parse(last_response.body)
          content.should eq(u)
        end

        it "authenticates a user by X_HEADERS with username" do

          post "/api/v1/sessions", {}, { 'HTTP_X_USERNAME' => 'a', 'HTTP_X_PASSWORD' => 'apples' } 
          last_response.status.should eq(201)

          content = JSON.parse(last_response.body)
          content.should eq(u)
        end

        it "authenticates a user by API_KEY" do
          post "/api/v1/sessions", { t: u.api_key }
          last_response.status.should eq(201)

          content = JSON.parse(last_response.body)
          content.should eq(u)
        end
      end
    end 

    describe "groups" do
      context "POST /groups" do
        it "creates a new group" do

          post "/api/v1/groups", { name: 'Wayne Enterprises', t: u.api_key }
          last_response.status.should eq(201)

          u.groups.length.should eq(2)
          u.memberships.length.should eq(2)
          u.memberships.last.group.should == u.groups.last
        end
      end

      context "DELETE /groups/:id" do
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
      
      describe "group members" do
        context "POST /groups/:id/users" do
          it "adds a user to the group" do
            post "/api/v1/groups/#{g.id}/users", {email: bono.email, t: u.api_key}
            last_response.status.should eq(201)

            g.users.should include(u,bono)
          end

          it "returns 404 if the user doesn't exist" do
            post "/api/v1/groups/#{g.id}/users", {email: 'c@foo.com', t: u.api_key}
            last_response.status.should eq(404)
          end

          it "returns 401 if the user is not an admin" do
            post "/api/v1/groups/#{g.id}/users", {email: 'c@foo.com', t: bono.api_key}
            last_response.status.should eq(401)
          end
        end

        context "PUT /groups/:group_id/users/:username" do
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

      describe "group clients" do
        let!(:client) { Client.create(name: "Wayne Enterprises") }
        context "POST /group/:group_id/clients" do
          it "adds a client to the group -- returns 201" do
            post "/api/v1/groups/#{g.id}/clients", { name: "Luthor Industries" , t: u.api_key } 
            last_response.status.should == 201
            Client.count.should == 2
          end

          it "refuses to add a client if one with the same name already exists -- returns 422" do
            post "/api/v1/groups/#{g.id}/clients", { name: client.name , t: u.api_key } 
            last_response.status.should == 422
          end

          it "refuses to add a client for a non-admin -- returns 401" do
            post "/api/v1/groups/#{g.id}/clients", { name: client.name , t: bono.api_key } 
            last_response.status.should == 401
          end
        end

        context "PUT group/:group_id/clients/:client_id" do
          it "updates the existing client -- returns 200"
          it "refuses to update for a non-admin -- returns 401"
          it "refuses to update a non-existant client -- returns 404"
        end

        context "DELETE group/:group_id/clients/:client_id" do
          it "destroys an existing client -- returns 200" 
          it "refuses to destroy a non-existent client -- returns 404"
          it "refuses to destroy for a non-admin -- returns 401"
        end

        describe "client projects" do
          context "POST group/:group_id/clients" do

          end

          context "PUT group/:group_id/clients/:client_id" do

          end

          context "DELETE group/:group_id/clients/:client_id" do

          end
        end
      end
    end
  end
end

