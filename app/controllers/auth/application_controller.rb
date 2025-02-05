module Auth
  class ApplicationController < ::ApplicationController
    include Auth::Authentication
    layout "auth/layout"
  end
end
