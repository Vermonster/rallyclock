require 'spec_helper'

describe RallyClock::API do
  def app
    RallyClock::API
  end

  context "v1" do
    let!(:u) { User.create(email: 'a@foo.com', password: 'apples', username: 'a') } 
    let!(:g) { Group.create(name: 'vermonster', handle: 'vermonster', owner_id: u.id) } 
    let!(:c) { Client.create(name: 'verm', account: 'verm', group_id: g.id) }
    let!(:p) { Project.create(name: 'rallyclock', code: 'r10', client_id: c.id) }
    let!(:bono) { User.create(email: 'b@foo.com', password: 'apples', username: 'bono') } 
    let!(:edge) { User.create(email: 'c@foo.com', password: 'apples', username: 'edge') } 

    before do
      Membership.create(user_id: u.id, group_id: g.id)
      Membership.create(user_id: bono.id, group_id: g.id)
    end

    context "system" do
      it "ping" do
        get "/api/v1/system/ping"
        last_response.body.should eq("pong")
      end
    end

    describe "entries" do
      context "creating" do
        context "POST /:handle/projects/:code/entries" do
          it "should create an entry for the submitting user" do
            post "/api/v1/#{g.handle}/projects/#{p.code}/entries", { t: bono.api_key, entry: { note: "Slurm", time: 420 } }
            last_response.status.should == 201
            bono.entries.should_not be_empty
          end
        end
      end

      context "update and delete" do
        let!(:entry) { Entry.create(note: "SLURM!", time: 420, user_id: u.id, project_id: p.id) }
        let!(:bono_entry) { Entry.create(note: "Sunday, Bloody Sunday.", time: 420, user_id: bono.id, project_id: p.id) }

        context "PUT /entries/:id" do
          it "should update the given entry with the new information" do
            put "/api/v1/#{g.handle}/projects/#{p.code}/entries/#{entry.id}", { t: u.api_key, entry: { note: "Slurm", time: 420 } }
            last_response.status.should == 200
            u.entries_dataset[entry.id].note.should == "Slurm"
            u.entries_dataset[entry.id].time.should == 420
          end

          it "should reject updating an entry that does not exist -- 404" do
            put "/api/v1/#{g.handle}/projects/#{p.code}/entries/#{bono_entry.id}", { t: u.api_key, entry: { note: "Slurm", time: 420 } }
            last_response.status.should == 401
          end

          it "should reject updating another users entry -- 401" do
            put "/api/v1/#{g.handle}/projects/#{p.code}/entries/123091230", { t: u.api_key, entry: { note: "Slurm", time: 420 } }
            last_response.status.should == 404
          end
        end

        context "DELETE /entries/:id" do
          it "should delete the given entry" do
            delete "/api/v1/#{g.handle}/projects/#{p.code}/entries/#{entry.id}", { t: u.api_key }
            last_response.status.should == 200
            u.entries.should be_empty
          end

          it "refuses to delete an entry not owned by the user -- 401" do
            delete "/api/v1/#{g.handle}/projects/#{p.code}/entries/#{bono_entry.id}", { t: u.api_key }
            last_response.status.should == 401
            bono.entries.should_not be_empty
          end

          it "refuses to delete an entry that does not exist -- 404" do
            delete "/api/v1/#{g.handle}/projects/#{p.code}/entries/123091230", { t: u.api_key }
            last_response.status.should == 404
            u.entries.should_not be_empty
          end
        end
      end
    end

    describe "users" do
      context "POST /users" do
        let!(:existing_user) { User.create(email: "descartes@cogito.ergo.sum", password: "foobar", username: "rene") }

        it "creates a user" do
          expect do
            post "/api/v1/users", { email: 'asdlfkj@foo.com', password: 'apples', username: 'sdfkljsd' }
          end.to change { User.count }.from(4).to(5)
          last_response.status.should eq(201)

          User.first(email: 'asdlfkj@foo.com').should_not be_nil
        end

        it "returns 422 if the Email has been taken" do
          post '/api/v1/users', { email: 'descartes@cogito.ergo.sum', password: "foo", username: "des" } 
          last_response.status.should eq(422)
        end

        it "returns 422 if the Username has been taken" do
          post '/api/v1/users', { email: 'des@cogito.ergo.sum', password: "foo", username: "rene" } 
          last_response.status.should eq(422)
        end

        it "rejects invalid emails" do
          post '/api/v1/users', { email: 'desogito.ergo.sum', password: "foo", username: "rasdlfkjasdf" } 
          last_response.status.should eq(403)
        end

        it "rejects usernames with invalid characters" do
          post '/api/v1/users', { email: 'des@cogito.ergo.sum', password: "foo", username: "r ne" } 
          last_response.status.should eq(403)
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
          post "/api/v1/groups", { group: { name: 'Wayne Enterprises', handle: 'wayne_corp'}, t: u.api_key }
          last_response.status.should eq(201)

          u.groups.length.should eq(2)
          u.memberships.length.should eq(2)
          u.memberships.last.group.should == u.groups.last
        end
      end

      context "DELETE :handle" do
        it "deletes a group" do
          delete "/api/v1/#{g.handle}", {t: u.api_key}
          last_response.status.should eq(200)
          u.groups.should be_empty
          u.memberships.should be_empty
        end

        it "returns 401 when trying to delete a unowned group" do
          delete "/api/v1/#{g.handle}", {t: bono.api_key}
          last_response.status.should eq(401)
          Group.count.should eq(1)
        end
      end

      describe "group members" do
        context "POST :handle/users" do
          it "adds a user to the group" do
            post "/api/v1/#{g.handle}/users", {email: edge.email, t: u.api_key}
            last_response.status.should eq(201)

            g.users.should include(u,bono)
          end

          it "returns 404 if the user doesn't exist" do
            post "/api/v1/#{g.handle}/users", {email: 'd@foo.com', t: u.api_key}
            last_response.status.should eq(404)
          end

          it "returns 401 if the user is not an admin" do
            post "/api/v1/#{g.handle}/users", {email: 'd@foo.com', t: bono.api_key}
            last_response.status.should eq(401)
          end
        end

        context "PUT /:handle/users/:username" do
          it "updates an existing user" do
            put "/api/v1/#{g.handle}/users/#{bono.username}", { :user => { admin: true }, t: u.api_key } 
            last_response.status.should eq(200)
            bono.should be_admin_of g
          end

          it "returns 404 if the user doesn't exist" do
            put "/api/v1/#{g.handle}/users/asldfkalsjdhflkajsdhfalskjdfhaskdjfh", { :user => { admin: true }, t: u.api_key }
            last_response.status.should eq(404)
          end

          it "returns 401 if the user is not an admin" do
            put "/api/v1/#{g.handle}/users/#{u.username}", { :user => { admin: true }, t: bono.api_key }
            last_response.status.should eq(401)
          end
        end

        context "DELETE /:handle/users/:username" do
          it "removes a user from the group" do
            g.users.should include(bono)
            delete "/api/v1/#{g.handle}/users/#{bono.username}", { t: u.api_key } 
            last_response.status.should eq(200)
            bono.memberships.should be_empty
          end

          it "returns 404 if the user doesn't exist" do
            delete "/api/v1/#{g.handle}/users/asldfkalsjdhflkajsdhfalskjdfhaskdjfh", { t: u.api_key }
            last_response.status.should eq(404)
          end

          it "returns 401 if the user is not an admin" do
            delete "/api/v1/#{g.handle}/users/#{u.username}", { t: bono.api_key }
            last_response.status.should eq(401)
          end
        end
      end

      describe "group clients" do
        let!(:client) { Client.create(name: "Wayne Enterprises", group_id: g.id, account: "BRRUUCE") }

        context "POST /:handle/clients" do
          it "adds a client to the group -- returns 201" do
            post "/api/v1/#{g.handle}/clients", { client: { account: "LEX", name: "Luthor Industries" } , t: u.api_key } 
            last_response.status.should == 201
            Client.count.should == 3
          end

          it "refuses to add a client if one with the same name already exists -- returns 422" do
            post "/api/v1/#{g.handle}/clients", { client: { account: client.account, name: client.name } , t: u.api_key } 
            last_response.status.should == 422
          end

          it "refuses to add a client for a non-admin -- returns 401" do
            post "/api/v1/#{g.handle}/clients", { client: { account: "LEX", name: "Luthor Industries" }, t: bono.api_key } 
            last_response.status.should == 401
          end
        end

        context "PUT :handle/clients/:id" do
          it "updates the existing client -- returns 200" do
            put "/api/v1/#{g.handle}/clients/#{client.account}", {t: u.api_key, client: {name: 'Bioware', account: "BIO"} }
            last_response.status.should eq(200)

            client.reload
            client.name.should eq('Bioware')
          end

          it "refuses to update for a non-admin -- returns 401" do
            put "/api/v1/#{g.handle}/clients/#{client.account}", { t: bono.api_key, client: { name: 'Bioware', account: "BIO"}}
            last_response.status.should eq(401)
          end

          it "refuses to update a non-existant client -- returns 404" do
            put "/api/v1/#{g.handle}/clients/asldkfjwoib", {t: u.api_key, client: {name: 'Bioware', account: "BIO"}}
            last_response.status.should eq(404)
          end
        end
        
        context "DELETE :handle/clients/:id" do
          it "destroys an existing client -- returns 200" do
            delete "/api/v1/#{g.handle}/clients/#{client.account}", {t: u.api_key}
            last_response.status.should eq(200)
          end

          it "refuses to destroy a non-existent client -- returns 404" do
            delete "/api/v1/#{g.handle}/clients/asdfkljasdflk", {t: u.api_key}
            last_response.status.should eq(404)
          end

          it "refuses to destroy for a non-admin -- returns 401" do
            delete "/api/v1/#{g.handle}/clients/#{client.account}", {t: bono.api_key}
            last_response.status.should eq(401)
          end
        end

        describe "client projects" do
          let!(:client) { Client.create(name: "Cyberdyne", group_id: g.id, account: "IMCLEO") }
          let!(:project) { Project.create(name: "Skynet", client_id: client.id, code: "WHOAREYOU") }

          context "POST :handle/clients/:client_id/projects" do
            it "adds a project to a client -- returns 201" do
              post "/api/v1/#{g.handle}/clients/#{client.account}/projects", { project: { name: "T-X", code: "TX" } , t: u.api_key } 
              last_response.status.should eq(201)
              Project.count.should eq(3)
            end

            it "refuses to add a client if one with the same name already exists -- returns 422" do
              post "/api/v1/#{g.handle}/clients/#{client.account}/projects", { 
                project: { name: project.name, code: project.code },
                t: u.api_key 
              } 
              last_response.status.should eq(422)
            end

            it "refuses to add a client for a non-admin -- returns 401" do
              post "/api/v1/#{g.handle}/clients/#{client.account}/projects", { project: { name: "T-Y", code: "TY" }, t: bono.api_key } 
              last_response.status.should eq(401)
            end
          end

          context "PUT :handle/clients/:client_id/projects/:id" do
            it "updates the existing project -- returns 200" do
              put "/api/v1/#{g.handle}/clients/#{client.account}/projects/#{project.code}", {
                t: u.api_key, 
                project: {name: 'T-1000', code: "T1000" }
              }
              last_response.status.should eq(200)

              project.reload
              project.name.should eq('T-1000')
            end

            it "refuses to update for a non-admin -- returns 401" do
              put "/api/v1/#{g.handle}/clients/#{client.account}/projects/#{project.code}", { 
                t: bono.api_key,
                project: { code: "T1000",  name: 'T-1000'}
              }
              last_response.status.should eq(401)
            end

            it "refuses to update a non-existant client -- returns 404" do
              put "/api/v1/#{g.handle}/clients/#{client.account}/projects/asdfkljasd", {
                t: u.api_key,
                project: { code: "T1000", name: 'T-1000'}
              }
              last_response.status.should eq(404)
            end
          end

          context "DELETE :handle/clients/:client_id/projects/:id" do
            it "destroys an existing project -- returns 200" do
              delete "/api/v1/#{g.handle}/clients/#{client.account}/projects/#{project.code}", {t: u.api_key}
              last_response.status.should eq(200)
            end

            it "refuses to destroy a non-existent project -- returns 404" do
              delete "/api/v1/#{g.handle}/clients/#{client.account}/projects/adsflkjass", {t: u.api_key}
              last_response.status.should eq(404)
            end

            it "refuses to destroy for a non-admin -- returns 401" do
              delete "/api/v1/#{g.handle}/clients/#{client.account}", {t: bono.api_key}
              last_response.status.should eq(401)
            end
          end
        end
      end
    end
  end
end

