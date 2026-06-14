module ApplicationHelper
  def qr_code_svg(url, size: 80)
    return if url.nil?

    qrcode = RQRCode::QRCode.new(url)
    qrcode.as_svg(
      viewbox: true,
      module_size: (size / qrcode.modules.length).ceil,
    ).html_safe
  end

  def base64_image_tag(attachment, **options)
    variant = attachment.variant(resize_to_limit: [200, 200])
    data = variant.processed.download
    content_type = variant.content_type
    base64 = Base64.strict_encode64(data)
    data_url = "data:#{content_type};base64,#{base64}"

    image_tag(data_url, **options)
  end
end
