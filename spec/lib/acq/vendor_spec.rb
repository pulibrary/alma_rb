require 'spec_helper'

describe Alma::Acq::Vendor do
  before(:all) do
    Alma.configure
  end

  describe '#find' do
    let(:vendorCode) { 'dum_vend_1' }
    let(:vendor) { described_class.send :find, vendorCode }

    it 'returns a Vendor object' do
      expect(vendor).to be_a Alma::Acq::Vendor
    end

    it 'has the expected vendor code' do
      expect(vendor.code).to eql vendorCode
    end
  end
end
