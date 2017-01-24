# frozen_string_literal: true
require 'rails_helper'
require 'bb/generate_report_request_form'
require 'bb/client'

describe BB::GenerateReportRequestForm do
  let(:eligible_data_classes) do
    BB::GenerateReportRequestForm::ELIGIBLE_DATA_CLASSES
  end

  let(:bb_client) do
    VCR.use_cassette 'bb_client/session', record: :new_episodes do
      client = BB::Client.new(session: { user_id: '12210827' })
      client.authenticate
      client
    end
  end

  let(:time_before) { Time.parse('2000-01-01T12:00:00-05:00').utc }
  let(:time_after)  { Time.parse('2016-01-01T12:00:00-05:00').utc }

  let(:attributes) { {} }

  subject { described_class.new(bb_client, attributes) }

  before(:each) { allow(subject).to receive(:eligible_data_classes).and_return(eligible_data_classes) }

  context 'with null attributes' do
    it 'responds to params' do
      expect(subject.params)
        .to eq(from_date: nil, to_date: nil, data_classes: [])
    end

    it 'returns valid false with errors' do
      expect(subject.valid?).to be_falsey
      expect(subject.errors.full_messages)
        .to eq([
                 'From date is not a date',
                 'To date is not a date',
                 "Data classes can't be blank"
               ])
    end
  end

  context 'with invalid dates' do
    let(:attributes) do
      { from_date: time_after.iso8601, to_date: time_before.iso8601, data_classes: eligible_data_classes }
    end

    it 'responds to params' do
      expect(subject.params)
        .to eq(from_date: time_after.httpdate, to_date: time_before.httpdate, data_classes: eligible_data_classes)
    end

    # This spec can be added again in the future if desired, but for now leave as MHV error
    xit 'returns valid false with errors' do
      expect(subject.valid?).to be_falsey
      expect(subject.errors.full_messages)
        .to eq(['From date must be before to date'])
    end
  end

  context 'with invalid data_classes' do
    let(:invalid_data_classes) { %w(blah blahblah) }
    let(:attributes) do
      { from_date: time_before.iso8601, to_date: time_after.iso8601, data_classes: invalid_data_classes }
    end

    it 'responds to params' do
      expect(subject.params)
        .to eq(from_date: time_before.httpdate, to_date: time_after.httpdate, data_classes: invalid_data_classes)
    end

    it 'returns valid true' do
      expect(subject.valid?).to be_falsey
      expect(subject.errors.full_messages)
        .to eq(['Invalid data classes: blah, blahblah'])
    end
  end

  context 'with valid attributes' do
    let(:attributes) do
      { from_date: time_before.iso8601, to_date: time_after.iso8601, data_classes: eligible_data_classes }
    end

    it 'responds to params' do
      expect(subject.params)
        .to eq(from_date: time_before.httpdate, to_date: time_after.httpdate, data_classes: eligible_data_classes)
    end

    it 'returns valid true' do
      expect(subject.valid?).to be_truthy
    end
  end
end
