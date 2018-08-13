require "spec_helper"

describe Alma::Electronic::Collection do
  before(:all) do
    Alma.configure
  end

  describe "#all" do
    let(:all) { described_class.all }

    it 'returns an enumerator' do
      expect(all).to be_a_kind_of Enumerator
    end

    it 'makes the request the API when enumeration starts ' do
      all.next
      expect(WebMock).to have_requested(:get, /.*\/e-collections.*/)
    end

    it 'handles requesting the second page of results transparently' do
      binding.pry
      all.map(&:keys)
      expect(WebMock).to have_requested(:get, /.*\/e-collections.*/).
        with(query: hash_including({offset: 100}))
    end


  end


end
