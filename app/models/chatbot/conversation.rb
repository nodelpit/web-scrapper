class Chatbot::Conversation < ApplicationRecord
  belongs_to :user
  has_many :messages, class_name: "Chatbot::Message", dependent: :destroy
end
