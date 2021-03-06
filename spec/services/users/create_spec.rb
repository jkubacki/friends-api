# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::Create do
  subject do
    described_class.call(
      email: "user@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  let(:user) { instance_double(User, :save, id: 1) }
  let(:save_result) { true }
  let(:mail) { double }

  before do
    allow(User).to receive(:new).and_return(user)
    allow(user).to receive(:save).and_return(save_result)
    allow(Users::ConfirmationMailer).to receive(:send_confirmation).and_return(mail)
    allow(mail).to receive(:deliver_later)
  end

  it "builds user with passed arguments" do
    expect(User).to(
      receive(:new)
        .with(email: "user@example.com", password: "password", password_confirmation: "password")
    ).once
    subject
  end

  context "when save returns true" do
    let(:save_result) { true }

    it { is_expected.to be_success }

    it "returns user in success" do
      expect(subject.value!).to eq user
    end

    it "enqueues confirmation email" do
      expect(mail).to receive(:deliver_later).once
      subject
    end
  end

  context "when save returns false" do
    let(:save_result) { false }

    it { is_expected.to be_failure }

    it "returns user in faulure" do
      expect(subject.failure).to eq user
    end

    it "doesn't enqueue confirmation email" do
      expect(mail).not_to receive(:deliver_later)
      subject
    end
  end
end
