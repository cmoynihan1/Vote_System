desc 'Count Votes From File [Text File => path to text file]'
task :count_votes, [:text_file] => :environment do |task, args|
  VOTE = 'VOTE'.freeze
  VALID_SECTIONS = %w(Campaign Validity Choice CONN MSISDN GUID Shortcode).freeze
  valid_lines = 0
  invalid_lines =0

  campaigns_to_ingest = CountingHash.new
  File.open(args[:text_file]).each do |line|
    begin
      sections = line.split(' ')
      validate_header(sections.shift)
      sections.shift #Skip epoch time section

      parse_vote(sections).tap do |vote|
        choice = vote['Validity'] == 'during'? vote['Choice'.freeze] : 'Invalid'.freeze
        campaigns_to_ingest.count_item(vote['Campaign'.freeze], choice)
        valid_lines+= 1
      end
    rescue MalformedLineError
      invalid_lines += 1
      next
    end
  end
  Campaign.ingest_campaigns(campaigns_to_ingest)

  puts "Ingestion complete."
  puts "#{valid_lines} lines were valid. #{invalid_lines} were invalid."
end

def parse_vote(sections)
  Hash.new.tap do |vote|
    VALID_SECTIONS.each do |section_key|
      section_key_value = sections.shift.split(':')
      key = section_key_value[0]
      value = section_key_value[1]
      validate_key(section_key, key)
      vote[key] = value
    end
  end
end

def validate_header(header)
  raise MalformedLineError unless header == VOTE
end

def validate_key(section_key, key)
  raise MalformedLineError unless section_key == key
end

class CountingHash < Hash
  def count_item(level1, level2)
    if self.has_key? level1
      self[level1]
    else
      self[level1] = {}
    end
    if self[level1].has_key? level2
      self[level1][level2] += 1
    else
      self[level1][level2] = 1
    end
  end
end

class MalformedLineError < StandardError; end