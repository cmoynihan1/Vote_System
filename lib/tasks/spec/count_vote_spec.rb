require "rails_helper"
Rails.application.load_tasks

describe 'count_vote.rake' do
  it 'should count votes' do
    Rake::Task["count_votes"].invoke('lib/tasks/spec/test_votes.txt')

  end
end