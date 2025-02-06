class ApplicationController < ActionController::Base
  include Auth::Authentication
  allow_browser versions: :modern
  protect_from_forgery with: :exception

  private

  def redirect_with_turbo_stream(path, flash_type, message)
    respond_to do |format|
      format.html do
        flash[flash_type] = message
        redirect_to path
      end
      format.turbo_stream do
        flash.now[flash_type] = message
        render turbo_stream: [
          turbo_stream.update("flash-messages", partial: "shared/flash_messages")
        ]
      end
    end
  end
end
