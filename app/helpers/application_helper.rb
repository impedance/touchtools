module ApplicationHelper
  def provider_badge_color(provider_type)
    case provider_type
    when 'lenta' then 'bg-blue-100 text-blue-700'
    when 'magnit' then 'bg-green-100 text-green-700'
    when 'dixy' then 'bg-purple-100 text-purple-700'
    when 'perekrestok' then 'bg-yellow-100 text-yellow-700'
    else 'bg-gray-100 text-gray-700'
    end
  end
end
