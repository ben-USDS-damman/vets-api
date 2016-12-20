# frozen_string_literal: true
require 'rails_helper'
require 'mvi/service'

describe MVI::Configuration do
  it 'does some stuff' do
    ENV['MOCK_MVI_SERVICE'] = "false"
    user = User.new(
      uuid: SecureRandom.uuid,
      first_name: 'KENT',
      middle_name: 'L',
      last_name: 'WARREN',
      birth_date: '1936-07-14',
      gender: 'M',
      ssn: '796127160',
      email: 'vets.gov.user+206@gmail.com',
      loa: {
        current: LOA::THREE,
        highest: LOA::THREE
      }
    )
    puts user.va_profile
  end
end
