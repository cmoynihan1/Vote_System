require "rails_helper"
describe Campaign do
  let(:test_ingestion){
    {
      'test' => { 'test candidate 1' => 1, 'test candidate 2' => 2, nil => 3, 'Invalid'  => 4},
      'test 2' => { 'test candidate 2' => 4 }
    }
  }
  before do
    Campaign.ingest_campaigns(test_ingestion)
  end
  it 'should ingest campaigns' do
    expect(Campaign.count).to eq(2)
    expect(Candidate.count).to eq(3)
    Campaign.find_by(campaign_id: 'test') do |campaign|
      expect(campaign.valid_votes).to eq(3)
      expect(campaign.error_votes).to eq(3)
      expect(campaign.invalid_votes).to eq(4)
    end
  end
  context 'with an empty ingestion' do
    let(:test_ingestion){ {  } }
    it 'should ingest campaigns' do
      expect(Campaign.count).to eq(0)
      expect(Candidate.count).to eq(0)
    end
  end

  context 'with a nil ingestion' do
    let(:test_ingestion){ nil }
    it 'should ingest campaigns' do
      expect(Campaign.count).to eq(0)
      expect(Candidate.count).to eq(0)
    end
  end
end


