# frozen_string_literal: true

Grover.configure do |config|
  config.options = {
    format: "A4",
    margin: {
      top: "10mm",
      bottom: "10mm",
      left: "10mm",
      right: "10mm",
    },
    print_background: true,
    display_header_footer: false,
    launch_args: ENV["PUPPETEER_EXECUTABLE_PATH"] ? ["--no-sandbox", "--disable-setuid-sandbox"] : [],
  }
end
