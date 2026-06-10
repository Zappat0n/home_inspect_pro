module ApplicationHelper
  def base64_image_tag(attachment, **options)
    variant = attachment.variant(resize_to_limit: [200, 200])
    data = variant.processed.download
    content_type = variant.content_type
    base64 = Base64.strict_encode64(data)
    data_url = "data:#{content_type};base64,#{base64}"

    image_tag(data_url, **options)
  end
end
