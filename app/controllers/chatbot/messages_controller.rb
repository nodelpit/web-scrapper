class Chatbot::MessagesController < ApplicationController
  include Auth::Authentication
  include Chatbot::Authorization

  before_action :authenticate_user!
  before_action :set_conversation
  before_action :ensure_conversation_owner

  def create
    @message = @conversation.messages.build(message_params)

    respond_to do |format|
      if @message.save
        format.turbo_stream do
          # Affiche uniquement le message utilisateur
          render turbo_stream: [
            turbo_stream.update("messages",
              partial: "shared/chatbot/conversations/messages",
              locals: { conversation: @conversation }
            ),
            turbo_stream.replace("messages-container",
              partial: "shared/chatbot/conversations/container",
              locals: { conversation: @conversation }
            )
          ]
        end

        # Lance le job en arrière-plan pour la réponse du bot
        Chatbot::BotResponseJob.perform_later(@conversation.id, @message.content)
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "conversation",
            partial: "shared/chatbot/conversations/messages",
            locals: { conversation: @conversation }
          )
        end
      end
    end
  end

  private

  def set_conversation
    @conversation = Chatbot::Conversation.find(params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:content).merge(sender_type: "user")
  end
end
