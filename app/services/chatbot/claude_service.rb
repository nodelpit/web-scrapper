module Chatbot
  class ClaudeService
    include HTTParty
    base_uri "https://api.anthropic.com"

    def initialize(message, conversation = nil)
      @message = message
      @conversation = conversation
    end

    def call
      make_request
    end

    private

    def make_request
      self.class.post("/v1/messages", headers: headers, body: body.to_json).parsed_response
    end

    def headers
      {
        "x-api-key" => api_key,
        "anthropic-version" => "2023-06-01",
        "content-type" => "application/json"
      }
    end

    def body
      {
        model: "claude-3-5-sonnet-20241022",
        max_tokens: 1024,
        system: "Sois toujours bref et direct dans tes réponses. Va droit au but et évite les détails inutiles.",
        messages: @conversation.messages.order(:created_at).map do |message|
          {
            role: message.sender_type == "user" ? "user" : "assistant",
            content: message.content
          }
        end + [
          {
            role: "user",
            content: @message
          }
        ]
      }
    end

    def api_key
      ENV["CLAUDE_API_KEY"]
    end
  end
end
