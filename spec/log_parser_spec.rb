require 'spec_helper'

describe Killjoy::LogParser do
  subject { Killjoy::LogParser.new }

  let(:line) do
    '68.146.201.97 - - [23/May/2015:00:08:05 -0400] "GET /hello HTTP/1.1" 502 1477 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36"'
  end

  it 'parses the ip address' do
    result = subject.parse(line)
    expect(result.ipaddress).to eql('68.146.201.97')
  end

  it 'parses the timestamp' do
    date = DateTime.parse("2015-05-23T00:08:05-04:00")
    timestamp = date.to_time.to_i
    expect(subject.parse(line).timestamp).to eql(timestamp)
  end

  it 'parses the url' do
    expect(subject.parse(line).url).to eql("/hello")
    expect(subject.parse(line).http_verb).to eql("GET")
    expect(subject.parse(line).http_version).to eql("HTTP/1.1")
  end

  it 'parses the response status code' do
    expect(subject.parse(line).http_status).to eql(502)
  end

  it 'parses the user agent' do
    expect(subject.parse(line).user_agent).to eql("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36")
  end

  it 'converts to json' do
    expected = JSON.parse("{\"timestamp\":1432354085,\"ipaddress\":\"68.146.201.97\",\"url\":\"/hello\",\"http_verb\":\"GET\",\"http_version\":\"HTTP/1.1\",\"http_status\":502,\"user_agent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36\"}")
    expect(JSON.parse(subject.parse(line).to_json)).to eql(expected)
  end

  it 'parses a blank user agent' do
    line = '85.25.103.50 - - [12/Oct/2015:04:31:50 -0400] "quit" 400 172 "-" "-"'
    log_line = subject.parse(line)

    expect(log_line.ipaddress).to eql('85.25.103.50')
    expect(log_line.http_status).to eql(400)
    expect(log_line.user_agent).to eql('-')
    expect(log_line.url).to be_nil
    expect(log_line.http_verb).to eql('quit')
    expect(log_line.http_version).to be_nil
  end
end
