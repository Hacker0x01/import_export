# frozen_string_literal: true

module ImportExport
  class Query
    class << self
      def countries
        @countries ||= IsoCountryCodes.all.map(&:alpha2)
      end

      def endpoint
        @endpoint ||= URI.join(ImportExport::API_BASE, 'search').to_s
      end
    end

    PARAMETERS = {
      q: nil,
      sources: Source.keys,
      countries: Query.countries,
      address: nil,
      name: nil,
      fuzzy_name: false,
      type: nil,
      types: nil,
      size: 50,
      offset: 0
    }.freeze

    TYPES = %w[
      Individual
      Entity
      Vessel
    ].freeze

    def initialize(params, api_key)
      params = { q: params } if params.is_a? String
      @params = PARAMETERS.merge(params)
      @api_key = api_key

      if invalid = @params.find { |key, _value| !PARAMETERS.key?(key) }
        raise ArgumentError, "Invalid parameter: #{invalid[0]}"
      end

      if invalid = @params[:sources].find { |source| !Source.find_by_key(source) }
        raise ArgumentError, "Invalid source: #{invalid}"
      end

      if invalid = @params[:countries].find { |country| !Query.countries.include?(country) }
        raise ArgumentError, "Invalid country: #{invalid}"
      end

      if invalid = !UUID.validate(api_key)
        raise ArgumentError, "Invalid API key: #{invalid}"
      end

      if invalid = @params[:size].to_i > 50
        raise ArgumentError, "API only accepts maximum size param of 50"
      end
    end

    def call
      RestClient.get Query.endpoint, {
        :params => params,
        'subscription-key' => api_key,
        'User-Agent' => ImportExport.user_agent
      }
    end

    private

    attr_reader :api_key

    def params
      params = @params.clone
      params[:countries] = params[:countries].join(',')
      params[:sources]   = params[:sources].join(',')
      params.reject { |_k, v| v.nil? }
    end
  end
end
