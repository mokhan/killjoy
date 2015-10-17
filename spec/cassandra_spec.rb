require 'spec_helper'

describe Killjoy::LogLineWriter do
  include_context 'with_cassandra'
  subject { Killjoy::LogLineWriter.new(session) }

  describe "#save" do
    let(:parser) { Killjoy::LogParser.new }
    let(:line) { '68.146.201.97 - - [23/May/2015:00:08:05 -0400] "GET /favicon.ico HTTP/1.1" 200 1150 "https://45.55.246.47/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36"' }
    let(:log_line) { parser.parse(line) }
    let(:json) { JSON.parse(log_line.to_json, symbolize_names: true) }

    it 'can insert into cassandra' do
      batch = session.batch do |x|
        subject.save(json) do |statement, parameters|
          x.add(statement, parameters)
        end
      end
      session.execute(batch)

      rows = session.execute("SELECT * FROM log_lines").to_a
      expect(rows.count).to eql(1)
      expect(rows[0]["ipaddress"]).to eql(IPAddr.new("68.146.201.97"))
    end
  end
end
