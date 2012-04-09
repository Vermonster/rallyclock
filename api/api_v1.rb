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
        
        delete nil do
          g = current_user.groups_dataset[params[:group_id].to_i]
          if g && g.owner?(current_user)
            g.destroy
          else
            error!('Unauthorized', 401)
          end
        end

        resource :users do
          post nil do
            g = current_user.groups_dataset[params[:group_id].to_i]

            if g && g.admin?(current_user)
              if u = User.first(email: params[:email])
                g.add_member(u)
              else
                error!("User does not exist", 404)
              end
            else
              error!("Unauthorized", 401)
            end
          end

          put ":username" do
            g = current_user.groups_dataset[params[:group_id].to_i]

            if g && g.admin?(current_user)
              if u = User.first(username: params[:username])
                g.add_admin(u)
              else
                error!("User does not exist", 404)
              end
            else
              error!("Unauthorized", 401)
            end
          end

          delete ":username" do
            g = current_user.groups_dataset[params[:group_id].to_i]

            if g && g.admin?(current_user)
              if u = User.first(id: params[:id].to_i)
                g.memberships.first(user_id: u.id).destroy
              else
                error!("User does not exist", 404)
              end
            else
              error!("Unauthorized", 401)
            end
          end
        end
      end
    end
  end
end
