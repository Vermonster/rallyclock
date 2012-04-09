module RallyClock
  class API_v1 < Grape::API
    version 'v1', :using => :path, :vendor => 'rallyclock', :format => :json
    rescue_from :all
    error_format :json

    helpers do
      def authenticate! 
        error!('Unauthorized', 401) unless current_user
      end

      def current_user
        @current_user ||= User.first(api_key: params[:t])
      end
    end

    resource :system do
      desc "Returns pong."
      get :ping do
        "pong"
      end
    end

    resource :users do
      post nil do
        u = User.new(email: params[:email], password: params[:password], username: params[:username])
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
          login = env['HTTP_X_USERNAME']
          password = env['HTTP_X_PASSWORD']
          user = User.authenticate(login, password).to_json
        end
      end
    end

    resource :groups do
      before { authenticate! }

      post nil do
        g = Group.create(name: params[:name])
        Membership.create(user_id: current_user.id, group_id: g.id, 
                          owner: true,
                          admin: true)
      end

      segment "/:group_id" do
        before do
          @group = current_user.groups_dataset[params[:group_id].to_i]
          error!("Unauthorized", 401) unless @group && @group.admin?(current_user)
        end
        
        delete nil do
          @group.destroy
        end

        resource :users do
          before do
            @user = User.filter({email: params[:email]}|{username: params[:username]}).first
            error!("User does not exist", 404) unless @user
          end

          post nil do
            @group.add_member(@user)
          end

          put ":username" do
            @group.add_admin(@user)
          end

          delete ":username" do
            @group.remove_member(@user)
          end
        end

        resource :clients do
          post nil do
            error!("Client Already Exists", 422) if Client.first(name: params[:name])
            Client.create(name: params[:name], group_id: @group.id)
          end
        end
      end
    end
    

  end
end
