# frozen_string_literal: true
require 'rails_helper'
require 'bb/generate_report_request_form'
require 'bb/client'

RSpec.describe 'prescriptions', type: :request do
  TOKEN = 'GkuX2OZ4dCE=48xrH6ObGXZ45ZAg70LBahi7CjswZe8SZGKMUVFIU88='

  def authenticated_client
    BB::Client.new(session: { user_id: 123,
                              expires_at: Time.current + 60 * 60,
                              token: TOKEN })
  end

  let(:current_user) { build(:mhv_user) }

  before(:each) do
    allow(BB::Client).to receive(:new).and_return(authenticated_client)
    use_authenticated_current_user(current_user: current_user)
  end

  context 'forbidden user' do
    let(:current_user) { build(:user) }

    it 'raises access denied' do
      get '/v0/health_records/refresh'

      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)['errors'].first['detail'])
        .to eq('You do not have access to health records')
    end
  end

  it 'responds to GET #refresh' do
    VCR.use_cassette('bb_client/gets_a_list_of_extract_statuses') do
      get '/v0/health_records/refresh'
    end

    expect(response).to be_success
    expect(response.body).to be_a(String)
    expect(response).to match_response_schema('extract_statuses')
  end

  it 'responds to GET #eligible_data_classes' do
    VCR.use_cassette('bb_client/gets_a_list_of_eligible_data_classes') do
      get '/v0/health_records/eligible_data_classes'
    end

    expect(response).to be_success
    expect(response.body).to be_a(String)
    expect(response).to match_response_schema('eligible_data_classes')
  end

  let(:params) do
    {
      from_date: 10.years.ago.iso8601,
      to_date: Time.now.iso8601,
      data_classes: BB::GenerateReportRequestForm::ELIGIBLE_DATA_CLASSES
    }
  end

  it 'responds to POST #create to generate a new report' do
    VCR.use_cassette('bb_client/generates_a_report') do
      post '/v0/health_records', params
    end

    expect(response).to be_accepted
    expect(response.body).to be_a(String)
    expect(response.body).to be_empty
  end

  it 'responds to GET #show to fetch the created report' do
    VCR.use_cassette('bb_client/gets_a_pdf_version_of_a_report') do
      get '/v0/health_records'
    end

    expect(response).to be_success
    expect(response.headers['Content-Disposition'])
      .to eq('inline; filename=mhv_GPTESTKFIVE_20161229_0057.pdf')
    expect(response.headers['Content-Transfer-Encoding']).to eq('binary')
    expect(response.headers['Content-Type']).to eq('application/pdf')
    expect(response.body).to be_a(String)
  end
end
