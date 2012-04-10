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
        error!('Username already taken', 422) if User.first(username: params[:username])
        error!('Email already taken', 422)    if User.first(email: params[:email])
        User.create(email: params[:email], password: params[:password], username: params[:username])
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
            error!("Client Already Exists", 422) if @group.clients_dataset.first(name: params[:name])
            Client.create(name: params[:name], group_id: @group.id)
          end

          segment "/:client_id" do
            before do
              error!("Client Does Not Exist", 404) unless @client = @group.clients_dataset[params[:client_id].to_i]
            end
          
            put nil do
              @client.update(params[:client])
            end

            delete nil do
              @client.destroy 
            end

            resource :projects do
              post nil do
                error!("Project Already Exists", 422) if @client.projects_dataset.first(name: params[:name])
                Project.create(name: params[:name], client_id: @client.id)
              end
  
              segment "/:project_id" do
                before do
                  error!("Project Does Not Exist", 404) unless @project = @client.projects_dataset[params[:project_id].to_i]
                end

                put nil do
                  @project.update(params[:project])
                end

                delete nil do
                  @project.destroy 
                end
              end
            end
          end
        end
      end
    end
    
    resource :entries do
      before { authenticate! }

      post nil do
        current_user.add_entry Entry.new(params[:entry])
      end

      segment '/:entry_id' do
        before do
          error!("Entry Not Found", 404) unless @entry = Entry.first(id: params[:entry_id])
          error!("Unauthorized", 401) unless current_user.entries.include?(@entry)
        end

        put nil do
          @entry.update(params[:entry]) 
        end

        delete nil do
          @entry.destroy
        end

      end
    end
  end
end
