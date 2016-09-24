# frozen_string_literal: true
module V0
  class DocumentsController < ApplicationController
    skip_before_action :authenticate

    def create
      params.require :file
      uploaded_io = params[:file]
      claim_id = params[:disability_claim_id]
      tracked_item_id = params[:tracked_item]

      DisabilityClaim.upload_document(claim_id, uploaded_io.original_filename,
                                      uploaded_io.read, tracked_item_id,
                                      current_user)
      head :no_content

    rescue ActionController::ParameterMissing => ex
      raise Common::Exceptions::ParameterMissing, ex.param
    end

    private

    def current_user
      @current_user ||= User.sample_claimant
    end
  end
end