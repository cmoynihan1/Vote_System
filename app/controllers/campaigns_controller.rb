# frozen_string_literal: true

class CampaignsController < ActionController::Base
  def index
    @campaigns = Campaign.all
  end

  def show
    @campaign = Campaign.find_by(campaign_id: params[:id])
  end
end
