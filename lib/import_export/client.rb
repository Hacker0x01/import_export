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

    def overall_total(params = {})
      response = Query.new(params, api_key).call
      JSON.parse(response)['total']
    end

    private

    def parse_response(response)
      JSON.parse(response)['results'].map { |data| Result.new(data) }
    end
  end
end
