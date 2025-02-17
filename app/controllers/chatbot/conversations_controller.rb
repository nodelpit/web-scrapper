class Chatbot::ConversationsController < ApplicationController
  include Auth::Authentication
  include Chatbot::Authorization

  before_action :authenticate_user!
  before_action :ensure_conversation_owner, only: [ :show, :destroy ]

  def index
    @conversations = current_user.chatbot_conversations
    @conversation = @conversations.find(params[:id]) if params[:id]
    @message = Chatbot::Message.new if @conversation
  end

  def show
    @conversation = Chatbot::Conversation.find(params[:id])
    @message = Chatbot::Message.new

    if request.xhr?
      render partial: "shared/chatbot/conversations/messages", locals: { conversation: @conversation }
    else
      redirect_to chatbot_conversations_path(id: @conversation.id)
    end
  end

  def create
    @conversation = current_user.chatbot_conversations.build

    if @conversation.save
      redirect_to chatbot_conversation_path(@conversation), notice: t(".success")
    else
      redirect_to chatbot_conversations_path, alert: @conversation.errors.full_messages.to_sentence
    end
  end

  def destroy
    @conversation.destroy
    redirect_to chatbot_conversations_path, notice: t(".success")
  end
end
