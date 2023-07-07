desc 'Count Votes From File [Text File => path to text file]'
task :count_votes, [:text_file] => :environment do |task, args|
  VOTE = 'VOTE'.freeze
  VALID_SECTIONS = %w(Campaign Validity Choice CONN MSISDN GUID Shortcode).freeze
  total_lines = 0
  valid_lines = 0

  campaigns_to_ingest = CountingHash.new
  File.open(args[:text_file]).each do |line|
    begin
      total_lines+= 1
      sections = line.split(' ')
      validate_header(sections.shift)
      sections.shift

      vote = parse_vote(sections)
      if vote['Validity'] == 'during'
        campaigns_to_ingest.count_item(vote['Campaign'.freeze], vote['Choice'.freeze])
        valid_lines+= 1
      else
        campaigns_to_ingest.count_item(vote['Campaign'.freeze], 'Invalid'.freeze)
        valid_lines += 1
      end
    rescue MalformedLineError
      next
    end
  end
  Campaign.ingest_campaigns(campaigns_to_ingest)

  puts "#{total_lines} parsed.  #{valid_lines} were valid."
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