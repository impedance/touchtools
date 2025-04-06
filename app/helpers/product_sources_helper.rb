module ProductSourcesHelper
    def provider_badge_color(provider_type)
      case provider_type
      when 'lenta' then 'bg-blue-100 text-blue-700'
      when 'magnit' then 'bg-green-100 text-green-700'
      when 'dixy' then 'bg-purple-100 text-purple-700'
      when 'perekrestok' then 'bg-yellow-100 text-yellow-700'
      else 'bg-gray-100 text-gray-700'
      end
    end
  
    def status_badge(status)
      classes = case status
                when 'active' then 'bg-green-100 text-green-800'
                when 'parsing' then 'bg-yellow-100 text-yellow-800'
                when 'error' then 'bg-red-100 text-red-800'
                else 'bg-gray-100 text-gray-800'
      end
      
      content_tag(:span, t("statuses.#{status}"),
        class: "inline-flex items-center px-3 py-1 rounded-full text-sm font-medium #{classes}")
    end
  end
