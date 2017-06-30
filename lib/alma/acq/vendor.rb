require 'nokogiri'
require 'active_support/core_ext/hash/conversions'
module Alma
  module Acq
    class Vendor < AlmaRecord
      extend Alma::Api
      extend Alma::Acq

      attr_accessor :code

      def post_initialize
        @code = @raw_record['vendor']['code'].to_s
      end

      def to_xml
        @xml ||= response.response.body
      end

      def update(new_xml)
        @xml = new_xml
        @raw_record = Hash.from_xml(@xml)
      end


      def push_update!
        local_params = {
          vendorCode: code,
          body: to_xml,
          headers: { "Content-Type" => 'application/xml'}
        }
        params = self.class.query_merge(local_params)
        self.class.resources.almaws_v1_acq.vendors_vendorCode.put(params)
      end

      def vendor_libs_xpath
        "/vendor/vendor_libraries/library"
      end

      def vendor_account_library_xpath
        "/vendor/accounts/account/account_libraries/library"
      end


      def add_vendor_library(libcode, desc)
        # Assumes the first library is Temple Alma organization
        # And that only a single Library would be in the secondary place

        fragment =
        "<library include_sub_units=\"false\">"\
        "<code desc=\"#{desc}\">#{libcode}</code>"\
        "</library>".strip

        node = Nokogiri::XML.fragment(fragment)


        xml = Nokogiri::XML(response.response.body)
        vendor_libraries_size  = xml.xpath(vendor_libs_xpath).length
        vendor_account_libs_size = xml.xpath(vendor_account_library_xpath).length

        xml.xpath(vendor_libs_xpath).each do |library|
          library.attributes["include_sub_units"].value = "false"
        end

        xml.xpath(vendor_account_library_xpath).each do |library|
          library.attributes["include_sub_units"].value = "false"
        end

        unless xml.xpath(vendor_libs_xpath).last.text.eql? libcode
          if vendor_libraries_size >= 2
            puts "Deleting last account lib for #{code}"
            xml.xpath(vendor_libs_xpath).last.remove
          end
          puts "Adding #{libcode} to last vendor lib for #{code}"
          xml.xpath(vendor_libs_xpath).last.next = node.dup
        else
          puts "#{libcode} already the last vendor lib for #{code} "
        end

        unless xml.xpath(vendor_account_library_xpath).last.text.eql? libcode
          if vendor_account_libs_size >= 2
            puts "Deleting last account lib for #{code}"
            xml.xpath(vendor_account_library_xpath).last.remove
          end
          puts "Adding #{libcode} to last account lib for #{code}"
          xml.xpath(vendor_account_library_xpath).last.next = node
        else
          puts "#{libcode} already the last account lib for #{code} "
        end

        update(xml.to_s)
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
