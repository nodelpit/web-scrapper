class CreateChatbotMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :chatbot_messages do |t|
      t.references :conversation, null: false, foreign_key: { to_table: :chatbot_conversations }
      t.text :content
      t.string :sender_type
      t.timestamps
    end
  end
end
