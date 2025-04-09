namespace :import do
  desc "Import product data from JSON file"
  task product_data: :environment do
    require 'json'
    require 'date'

    file_path = 'tmp/kolba.json'

    ImportProductDataJob.perform_later(file_path)

    puts "Import job enqueued successfully."
  end
end
