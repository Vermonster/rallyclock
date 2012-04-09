module RallyClock
  class API_v1 < Grape::API
    version 'v1', :using => :path, :vendor => 'rallyclock', :format => :json
    rescue_from :all
    error_format :json

    resource :system do
      desc "Returns pong."
      get :ping do
        "pong"
      end
    end

    resource :users do
      post nil do
        u = User.new(email: params[:email], password: params[:password])
        if u.valid?
          u.save
        else
          error!(u.errors.full_messages, 400)
        end
      end
    end

    resource :sessions do
      post nil do
        if params['t']
          User.first(api_key: params['t']).to_json
        else
          email = env['HTTP_X_USERNAME']
          password = env['HTTP_X_PASSWORD']
          user = User.authenticate(email, password).to_json
        end
      end
    end
  end
end
