class Chatbot::Message < ApplicationRecord
  belongs_to :conversation, class_name: "Chatbot::Conversation"
  validates :content, presence: true
  validates :sender_type, inclusion: { in: [ "user", "bot" ] }
end
