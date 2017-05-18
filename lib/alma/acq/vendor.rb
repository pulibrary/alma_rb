module Alma
  module Acq
    class Vendor < AlmaRecord
      extend Alma::Api
      extend Alma::Acq

      #attr_accessor :code

      def post_initialize
        #@code = response['code'].to_s
      end

      def push_update!
        local_params = { vendorCode: vendor_record.code, body: self.raw_record }
        params = query_merge(local_params)
        resources.almaws_v1_acq.vendors_vendorCode.put(params)
      end

      class << self
        def find(args)
          params = query_merge args
          response = resources.almaws_v1_acq.vendors_vendorCode.get(params)
          binding.pry
          Alma::Acq::Vendor.new(response['vendor'])
        end
      end
    end
  end
end
