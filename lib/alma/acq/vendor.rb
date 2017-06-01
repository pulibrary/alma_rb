require 'nokogiri'
require 'active_support/core_ext/hash/conversions'
module Alma
  module Acq
    class Vendor < AlmaRecord
      extend Alma::Api
      extend Alma::Acq

      attr_accessor :code

      def post_initialize
        @code = response['vendor']['code'].to_s
      end

      def to_xml
        @xml ||= response.response.body
      end

      def update(new_xml)
        @xml = new_xml
        @raw_record = Hash.from_xml(@xml)
      end


      def push_update!
        local_params = { vendorCode: code, body: to_xml }
        params = query_merge(local_params)
        resources.almaws_v1_acq.vendors_vendorCode.put(params)
      end

      def vendor_libs_xpath
        "/vendor/vendor_libraries"
      end


      def add_vendor_library(code, desc)
        # Assumes the first library is Temple Alma organization
        # And that only a single Library would be in the secondary place

        fragment =
        "<library include_sub_units=\"false\">"\
        "<code desc=\"#{desc}\">#{code}</code>"\
        "</library>".strip

        node = Nokogiri::XML.fragment(fragment)


        xml = Nokogiri::XML(to_xml)
        vendor_libraries  = xml.xpath(vendor_libs_xpath)

        if vendor_libraries.length >= 1
          vendor_libraries.pop
          binding.pry
        end

        binding.pry

        xml.xpath(vendor_libs_xpath) << node
        binding.pry

        update(xml.to_s)
      end

      def exclude_sub_units!
        vendor_libraries.each do |library|
          library.attributes["include_sub_units"].value = "false"
        end
        update(parsed_xml.to_s)
      end

      class << self
        def find(vendorCode)
          params = query_merge({ vendorCode: vendorCode })
          response = resources.almaws_v1_acq.vendors_vendorCode.get(params)
          Alma::Acq::Vendor.new(response)
        end
      end
    end
  end
end
