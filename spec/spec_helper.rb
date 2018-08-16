$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "alma"
require 'pry'
require 'webmock/rspec'
require 'simplecov'
require 'ostruct'
SimpleCov.start

SPEC_ROOT = File.dirname __FILE__

def load_user(args=nil)
  args ||= {body: {'primary_id' => 12}}
  fake_response = OpenStruct.new(args)
  Alma::User.new(fake_response)
end

RSpec.configure do |config|
  config.before(:each) do

    Alma.configure

    #fees / fines
    stub_request(:get, /.*\.exlibrisgroup\.com\/almaws\/v1\/users\/12\/fees\/.*/).
        to_return(:status => 200,
                  :body => File.open(SPEC_ROOT + '/fixtures/fines.json').read)


    # User details
    stub_request(:get, /.*\.exlibrisgroup\.com\/almaws\/v1\/users\/.*/).
        to_return(:status => 200,
                  :body => File.open(SPEC_ROOT + '/fixtures/single_user.json').read)

    # user requests
    stub_request(:get, /.*\.exlibrisgroup\.com\/almaws\/v1\/users\/.*\/requests/).
        to_return(:status => 200,
                  :body => File.open(SPEC_ROOT + '/fixtures/requests.json'))

    # successful user authentication
    stub_request(:post, /.*\.exlibrisgroup\.com\/almaws\/v1\/users\/.*/).
        with(query: hash_including({password: 'right_password'})).
        to_return(:status => 204)

    # failed user authentication
    stub_request(:post, /.*\.exlibrisgroup\.com\/almaws\/v1\/users\/.*/).
        with(query: hash_including({password: 'wrong_password'})).
        to_return(:status => 400)

    # renew user loan
    stub_request(:post, /.*\.exlibrisgroup\.com\/almaws\/v1\/users\/.*\/loans\/.*/).
        with(query: hash_including({op: 'renew'})).
        to_return(:status => 200,
                  :body => File.open(SPEC_ROOT + '/fixtures/renewal_success.json'))


    # Request bibs info

    stub_request(:get, /.*\.exlibrisgroup\.com\/almaws\/v1\/bibs/).
        to_return(:status => 200,
                  :body => File.open(SPEC_ROOT + '/fixtures/multiple_bibs.json'))

    stub_request(:get, /.*\.exlibrisgroup\.com\/almaws\/v1\/bibs\/.*\/holdings\/.*\/items/).
        to_return(:status => 200,
                  :body => File.open(SPEC_ROOT + '/fixtures/bib_items.json'))

    # Request options

    stub_request(:get, /.*\.exlibrisgroup\.com\/almaws\/v1\/bibs\/.*\/request-options/).
        to_return(:status => 200,
                  :body => File.open(SPEC_ROOT + '/fixtures/request_options.json'))

    stub_request(:get, /.*\.exlibrisgroup\.com\/almaws\/v1\/bibs\/NOHOLD\/request-options/).
        to_return(:status => 200,
                  :body => File.open(SPEC_ROOT + '/fixtures/request_options_no_hold.json'))

    stub_request(:post, /.*\.exlibrisgroup\.com\/almaws\/v1\/bibs\/foo\/requests/).
        to_return(:status => 200)

    stub_request(:get,/.*\/error/).
        to_return(:status => 400,
                  :body => File.open(SPEC_ROOT + '/fixtures/error.json'))

    # Item Level Request options

    stub_request(:get, /.*\.exlibrisgroup\.com\/almaws\/v1\/bibs\/.*\/holdings\/.*\/items\/.*\/request-options/).
        to_return(:status => 200,
                  :body => File.open(SPEC_ROOT + '/fixtures/request_options.json'))

    stub_request(:get, /.*\.exlibrisgroup\.com\/almaws\/v1\/bibs\/ITEMNOHOLD\/holdings\/123\/items\/456\/request-options/).
        to_return(:status => 200,
                  :body => File.open(SPEC_ROOT + '/fixtures/request_options_no_hold.json'))

    stub_request(:post, /.*\.exlibrisgroup\.com\/almaws\/v1\/bibs\/.*\/holdings\/.*\/items\/.*\/requests/).
        to_return(:status => 200)

  end
end
