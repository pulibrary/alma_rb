# frozen_string_literal: true

require "forwardable"

class Alma::ResultSet
  extend ::Forwardable
  include Enumerable
  include Alma::Error

  attr_reader :response, :raw_response

  def_delegators :response, :[], :fetch
  def_delegators :each, :each_with_index, :size

  def initialize(raw_response)
    @raw_response = raw_response
    @response = JSON.parse(raw_response.body)
  end

  def records
    @records ||= @response.fetch(key, [])
      .map { |item| single_record_class.new(item) }
  end

  def each(&block)
    records.each(&:block)
  end

  def total_record_count
    fetch("total_record_count", 0).to_i
  end
  alias :total_records :total_record_count

  protected
    def key
      raise NotImplementedError "Subclasses of ResultSet need to define a response key"
    end

    def single_record_class
      Alma::AlmaRecord
    end
end
