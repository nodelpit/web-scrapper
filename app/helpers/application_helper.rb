module ApplicationHelper
  def render_flash_messages(type)
    case type.to_s
    when "notice"
      "bg-green-200 border-2 border-green-500 text-green-600 rounded-lg shadow-lg"
    when "alert"
      "bg-red-200 border-2 border-red-500 text-red-500 rounded-lg shadow-lg"
    else
      "bg-yellow-500/90 text-white rounded-lg shadow-lg"
    end
  end
end
