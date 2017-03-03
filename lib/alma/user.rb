module Alma
  class  User < AlmaRecord

    include Alma::UserBehavior

    attr_accessor :alma_id

    def post_initialize
      @alma_id = response['primary_id'].to_s
    end
  end
end