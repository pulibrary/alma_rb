module Alma
  module Electronic
    class CollectionSet < Alma::ResultSet

      attr_reader :raw_response, :results
      def_delegators :results, :empty?

      def initialize(raw_response)
        @raw_response = raw_response
        @response = JSON.parse(raw_response.body)
        @results = @response.fetch(key, [])
          .map { |item| single_record_class.new(item) }
      end

      #TODO
      def each(&block)
        @results.each(&block)
      end


      def key
        'electronic_collection'
      end

      def single_record_class
        Alma::Electronic::Collection
      end

    end
  end
end
