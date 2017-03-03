module Alma
  class  User < AlmaRecord

    include Alma::UserBehavior

    attr_accessor :id

    def post_initialize
      @id = response['primary_id'].to_s
    end
  end
end