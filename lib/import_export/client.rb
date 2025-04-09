# frozen_string_literal: true

module ImportExport
  class Client
    class << self
      def search(options = {})
        Client.new.search(options)
      end
    end

    def initialize(options = {})
      @api_key = options[:api_key]
    end

    def api_key
      @api_key || ENV['TRADE_API_KEY']
    end

    def search(params = {})
      parse_response Query.new(params, api_key).call
    end

    private

    def parse_response(response)
      payload = JSON.parse(response)
      ResultsArray.new(payload['results'].map { |data| Result.new(data) }).tap do |results|
        results.total_results = payload['total']
      end
    end
  end

  class ResultsArray < Array
    attr_accessor :total_results
  end
end
