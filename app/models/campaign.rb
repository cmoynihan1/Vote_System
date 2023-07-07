class Campaign < ApplicationRecord
  has_many :candidates

  def self.ingest_campaigns(campaigns)
    campaigns&.each do |campaign, candidates|
      Campaign.find_or_create_by(campaign_id: campaign).tap do |campaign|
        candidates.each do |candidate, count|
          if candidate.blank?
            campaign.error_votes += count
            next
          end

          if candidate == 'Invalid'.freeze
            campaign.invalid_votes += count
            next
          end

          campaign.candidates.find_or_create_by(name: candidate, campaign_id: campaign).tap do |candidate|
            candidate.votes += count
            campaign.valid_votes += count
            candidate.save
          end
        end
      end.save
    end
  end

  def total_bad_votes
    invalid_votes + error_votes
  end

  def total_votes
    valid_votes + invalid_votes + error_votes
  end
end
