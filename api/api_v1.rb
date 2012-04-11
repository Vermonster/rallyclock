module RallyClock
  class API_v1 < Grape::API
    use Rack::Config do |env|
      env['api.tilt.root'] = File.expand_path("../../rabl", __FILE__)
    end

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

    before do
      @version = 'v1'
    end

    resource :system do
      desc "Returns pong."
      get :ping do
        "pong"
      end
    end

    resource :me do
      get nil, :rabl => 'me/user' do
        @user = current_user
      end

      resource :projects do
        get nil, :rabl => 'me/projects' do
          @projects = Project.filter(:client_id => current_user.groups.map(&:clients).flatten.map(&:id)).all
        end
      end

      resource :entries do
        get nil, :rabl => 'me/entries' do
          @entries = current_user.entries
        end
      end
    end

    resource :users do
      post nil do
        error!('Username already taken', 422) if User.first(username: params[:username])
        error!('Email already taken', 422)    if User.first(email: params[:email])
        u = User.new(email: params[:email], password: params[:password], username: params[:username])
        error!('Invalid Username or Email', 403) unless u.valid?
        u.save
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
        Membership.create(user_id: current_user.id, group_id: g.id, admin: true)
      end

      segment "/:group_id" do
        before do
          @group = Group[params[:group_id].to_i]
          error!("Group Not Found", 404) unless @group
          error!("Unauthorized", 401)    unless @group.admin?(current_user)
        end
        
        delete nil do
          @group.destroy
        end

        get(nil, :rabl => 'groups/show') {}

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

        resource :entries do
          get nil, :rabl => 'entries/index' do
            @entries = Project.filter(client_id: @group.clients_dataset.map(:id)).map(&:entries).flatten
          end

          segment "/:entry_id" do
            before do
              @entry = Entry[params[:entry_id].to_i]
              error!("Entry Not Found", 404) unless @entry
              error!("Unauthorized", 401) unless @group.users_dataset[@entry.user_id]
            end
            
            get(nil, :rabl => 'entries/show') {}
          end
        end

        resource :clients do
          post nil do
            error!("Client Already Exists", 422) if @group.clients_dataset.first(account: params[:client][:account])
            @group.add_client Client.new(params[:client])
          end

          segment "/:client_account" do
            before do
              error!("Client Not Found", 404) unless @client = @group.clients_dataset.first(account: params[:client_account])
            end
          
            put nil do
              @client.update(params[:client])
            end

            delete nil do
              @client.destroy 
            end

            get(nil, :rabl => 'clients/show') {}

            resource :entries do
              get nil, :rabl => 'entries/index' do
                @entries = Entry.filter(project_id: @client.projects_dataset.map(:id)).all
              end

              segment "/:entry_id" do
                before do
                  @entry = Entry[params[:entry_id].to_i]
                  error!("Entry Not Found", 404) unless @entry
                  error!("Unauthorized", 401) unless @client.projects_dataset[@entry.project_id]
                end
                
                get(nil, :rabl => 'entries/show') {}
              end
            end

            resource :projects do
              post nil do
                error!("Project Already Exists", 422) if @client.projects_dataset.first(code: params[:project][:code])
                @client.add_project Project.new(params[:project])
              end
  
              segment "/:project_code" do
                before do
                  error!("Project Does Not Exist", 404) unless @project = @client.projects_dataset.first(code: params[:project_code])
                end

                put nil do
                  @project.update(params[:project])
                end

                delete nil do
                  @project.destroy 
                end

                get(nil, :rabl => 'projects/show') {}
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
      
        get(nil, :rabl => 'entry') {}
      end
    end
  end
end
