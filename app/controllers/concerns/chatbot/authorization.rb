module Chatbot
  module Authorization
    extend ActiveSupport::Concern

    private

    def ensure_conversation_owner
      @conversation = Chatbot::Conversation.find(params[:conversation_id] || params[:id])
      unless @conversation.user == current_user
        redirect_to root_path, alert: t("chatbot.authorization.unauthorized_access")
      end
    end
  end
end
