json.array!(@enquiries) do |enquiry|
  json.extract! enquiry, :id, :first_name, :last_name, :email, :phone
  json.url enquiry_url(enquiry, format: :json)
end
