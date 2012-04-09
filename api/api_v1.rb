module RallyClock
  class API_v1 < Grape::API
    version 'v1', :using => :path, :vendor => 'rallyclock', :format => :json
    resource :system do
      desc "Returns pong."
      get :ping do
        "pong"
      end
    end

    resource :users do
      post nil do
        error!("error!", 400) unless params[:email] && params[:password]
        User.create(email: params[:email], password: params[:password])
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
