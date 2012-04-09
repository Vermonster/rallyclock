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
          post "/api/v1/users", { email: 'a@foo.com', password: 'apples' }
        end.to change { User.count }.from(0).to(1)
        last_response.status.should eq(201)

        User.first(email: 'a@foo.com').should_not be_nil
      end

      it "returns errors if they exist" do
        post "/api/v1/users"
        last_response.status.should eq(400)

        #content = JSON.parse(last_response.body)
        # binding.pry
      end
    end

    context "POST /sessions" do
      it "authenticates a user by X_HEADERS" do
        u = User.create(email: 'a@foo.com', password: 'apples')  
      
        post "/api/v1/sessions", {}, { 'HTTP_X_USERNAME' => 'a@foo.com', 'HTTP_X_PASSWORD' => 'apples' } 
        last_response.status.should eq(201)

        content = JSON.parse(last_response.body)
        content.should eq(u)
      end

      it "authenticates a user by API_KEY" do
        u = User.create(email: 'a@foo.com', password: 'apples')
        token = u.api_key

        post "/api/v1/sessions", {t: token}
        last_response.status.should eq(201)
        
        content = JSON.parse(last_response.body)
        content.should eq(u)
      end
    end
  end
end

