namespace :import do
  desc "Import product data from JSON file"
  task product_data: :environment do
    require 'json'
    require 'date'

    file_path = 'tmp/kolba.json'
    json_data = File.read(file_path)
    data = JSON.parse(json_data)

    user_id = 1
    provider_type = 'megamarket'

    product_source = ProductSource.create!(
      user_id: user_id,
      url: data['link'],
      provider_type: provider_type,
      name: data['name']
    )

    data['rating'].each do |rating_entry|
      date_str = "#{rating_entry['date']}.2024"
      collected_at = DateTime.strptime(date_str, '%d.%m.%Y')

      ProductMetric.create!(
        product_source_id: product_source.id,
        rating: rating_entry['rating'].to_f,
        collected_at: collected_at
      )
    end

    puts "Import completed successfully."
  end
end
