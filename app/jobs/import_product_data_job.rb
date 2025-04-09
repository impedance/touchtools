# app/jobs/import_product_data_job.rb
class ImportProductDataJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    require 'json'
    require 'date'

    json_data = File.read(file_path)
    data = JSON.parse(json_data)

    user_id = 1

    product_source = ProductSource.create!(
      user_id: user_id,
      url: data['link'],
      provider_type: data['provider_type'],
      name: data['name']
    )

    begin
      parser = Parser::ParserFactory.create(product_source)
      parsed_data = parser.get_product_info(product_source.url)

      if parsed_data && parsed_data[:рейтинг] # LentaParser
        ProductMetric.create!(
          product_source_id: product_source.id,
          rating: parsed_data[:рейтинг],
          collected_at: Time.now
        )
      elsif parsed_data && parsed_data[:рейтинг] # MagnitParser
        ProductMetric.create!(
          product_source_id: product_source.id,
          rating: parsed_data[:рейтинг],
          collected_at: Time.now
        )
      else
        Rails.logger.warn "No rating found in parsed data for #{product_source.url}"
      end

    rescue => e
      Rails.logger.error "Error parsing product data: #{e.message}"
    end
  end
end
