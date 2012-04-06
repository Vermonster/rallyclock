module RallyClock
  class API < Grape::API
    prefix 'api'
    mount ::RallyClock::API_v1
  end
end

