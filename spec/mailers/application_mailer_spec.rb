# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  describe "default configuration" do
    it "has the correct default from address" do
      expect(described_class.default[:from]).to eq("notifications@homeinspectpro.com")
    end
  end

  describe "delivering a test email" do
    it "sends an email and adds it to deliveries" do
      mailer = Class.new(described_class) do
        def test_email
          mail(to: "test@example.com", subject: "Test", body: "Hello")
        end
      end

      expect do
        mailer.test_email.deliver_now
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "sets the correct from address on the delivered email" do
      mailer = Class.new(described_class) do
        def test_email
          mail(to: "test@example.com", subject: "Test", body: "Hello")
        end
      end

      mailer.test_email.deliver_now

      email = ActionMailer::Base.deliveries.last
      expect(email.from).to contain_exactly("notifications@homeinspectpro.com")
    end

    it "sets the correct to address on the delivered email" do
      mailer = Class.new(described_class) do
        def test_email
          mail(to: "test@example.com", subject: "Test", body: "Hello")
        end
      end

      mailer.test_email.deliver_now

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to contain_exactly("test@example.com")
    end

    it "sets the correct subject on the delivered email" do
      mailer = Class.new(described_class) do
        def test_email
          mail(to: "test@example.com", subject: "Test", body: "Hello")
        end
      end

      mailer.test_email.deliver_now

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq("Test")
    end

    it "sets the correct body on the delivered email" do
      mailer = Class.new(described_class) do
        def test_email
          mail(to: "test@example.com", subject: "Test", body: "Hello")
        end
      end

      mailer.test_email.deliver_now

      email = ActionMailer::Base.deliveries.last
      expect(email.body.encoded).to include("Hello")
    end
  end
end
