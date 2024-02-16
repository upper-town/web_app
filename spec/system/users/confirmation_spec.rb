# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'confirmation page' do
  it 'fills in email address and sends confirmail email' do
    visit(users_sign_up_path)

    fill_in('Email', with: 'user@gmail.com')
    click_on('Send confirmation email')

    expect(page).to have_content('Please pass the captcha')

    check_captcha
    click_on('Send confirmation email')

    expect(page).to have_content('Confirmation link has been sent to your email')
  end
end
