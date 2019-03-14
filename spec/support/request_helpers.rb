module Requests
  module JsonHelpers
    def response_as_json
      JSON.parse(response.body)
    end
  end
end
