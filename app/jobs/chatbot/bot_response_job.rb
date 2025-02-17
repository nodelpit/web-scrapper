# Gère la réponse asynchrone du bot via un job en arrière-plan
class Chatbot::BotResponseJob < ApplicationJob
  queue_as :default

  def perform(conversation_id, user_message)
    # Récupère la conversation
    conversation = Chatbot::Conversation.find(conversation_id)

    # Appelle l'API de Claude pour obtenir la réponse
    service = Chatbot::ClaudeService.new(user_message, conversation)
    response = service.call

    # Crée le message du bot dans la base de données
    conversation.messages.create!(
      content: response.dig("content", 0, "text"),
      sender_type: "bot"
    )

    # Diffuse la mise à jour des messages via Turbo Streams
    Turbo::StreamsChannel.broadcast_update_to(
      "conversation_#{conversation.id}",
      target: "messages",
      partial: "shared/chatbot/conversations/messages",
      locals: { conversation: conversation.reload }
    )

    # Remplace le conteneur de messages pour le défilement
    Turbo::StreamsChannel.broadcast_replace_to(
      "conversation_#{conversation.id}",
      target: "messages-container",
      partial: "shared/chatbot/conversations/container",
      locals: { conversation: conversation.reload }
    )
  end
end
