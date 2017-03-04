json.extract! phone, :id, :name, :description, :price, :created_at, :updated_at
json.url phone_url(phone, format: :json)
