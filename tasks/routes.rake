namespace :api do
  desc "Displays all API methods."
  task 'routes' => :environment do
    Api.routes.each do |route|
      route_path = route.route_path.gsub('(.:format)', '').gsub(':version', route.route_version)
      puts "#{route.route_method} #{route_path}"
      puts " #{route.route_description}" if route.route_description
      if route.route_params.is_a?(Hash)
        params = route.route_params.map do |name, desc|
          required = desc.is_a?(Hash) ? desc[:required] : false
          description = desc.is_a?(Hash) ? desc[:description] : desc.to_s
          [ name, required, "   * #{name}: #{description} #{required ? '(required)' : ''}" ]
        end
        puts "  parameters:"
        params.each { |p| puts p[2] }
      end
    end
  end
end

