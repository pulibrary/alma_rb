module Alma
  module Electronic
    class Collection
      extend Alma::ApiDefaults
      extend Forwardable

      attr_reader :item
      def_delegators :item, :[], :has_key?, :keys, :to_json

      def initialize(response_hash)
        @item = response_hash
      end

      def self.all
        Enumerator.new do |yielder|
          offset = 0
          loop do
            puts "offset: #{offset}"
            results = self.where(limit: 100, offset: offset)
            unless results.empty?
              puts "results not empty"
              results.map { |item| yielder << item }
              puts " post mapping"
              offset += 100
            else
              puts "stopping iteration"
              raise StopIteration
            end
          end
        end.lazy
      end

      def self.find(id)
        response = HTTParty.get(
          "#{electronic_base_path}/e-collections/#{id}",
          headers: self.headers)
        new(response)
      end

      def self.where(options = {})
        puts "This API is super slow. "
        response = HTTParty.get(
          "#{electronic_base_path}/e-collections",
          query: options, headers: headers)
        Alma::Electronic::CollectionSet.new(response)
      end

    end
  end
end
