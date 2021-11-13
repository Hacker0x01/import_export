# frozen_string_literal: true

require 'spec_helper'

describe ImportExport::Query do
  subject { described_class.new({ q: 'smith' }, 'e835b25e-3ac0-4bbf-ba45-8a4b2eca5237') }

  it 'returns the country list' do
    expect(described_class.countries.count).to be(249)
    expect(described_class.countries.first).to eql('AF')
  end

  it 'builds the endpoint' do
    expected = 'https://data.trade.gov/consolidated_screening_list/v1/search'
    expect(described_class.endpoint).to eql(expected)
  end

  it 'accepts params as a hash' do
    expect(subject.instance_variable_get('@params')[:q]).to eql('smith')
  end

  it 'accepts params as a string' do
    query = described_class.new('smith', 'e835b25e-3ac0-4bbf-ba45-8a4b2eca5237')
    expect(query.instance_variable_get('@params')[:q]).to eql('smith')
  end

  it 'merges the default params' do
    expect(subject.instance_variable_get('@params')[:offset]).to be(0)
  end

  it 'builds the param lists' do
    expect(subject.send(:params)[:countries]).to match(/AF,AX/)
    expect(subject.send(:params)[:sources]).to match(/CAP,DPL/)
  end

  it 'strips empty params' do
    count = subject.send(:params).count { |_k, v| v.nil? }
    expect(count).to be(0)
  end

  it 'calls the API' do
    json = '{"results": [{"foo": "bar"}]}'
    stub = stub_request(:get, %r{https://data\.trade\.gov/consolidated_screening_list/v1/search.*})
           .to_return(status: 200, body: json)

    expect(subject.call).to eql(json)
    expect(stub).to have_been_requested
  end
end
