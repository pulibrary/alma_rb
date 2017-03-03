module Alma
  module UserBehavior

    def UserBehavior.included(klass)
      klass.extend Alma::UserQueryable
      puts "#{klass} included #{self}"

    end


    def fines
      @fines ||= fines!
    end

    def fines!
      self.class.get_fines({user_id: self.alma_id})
    end

    def loans
        @loans ||= loans!
    end

    def loans!
      self.class.get_loans({user_id: self.alma_id})
    end

    def renew_loan(loan_id)
      self.class.renew_loan({user_id: self.alma_id, loan_id: loan_id})
    end

    def renew_multiple_loans(loan_ids)
      loan_ids.map { |id| renew_loan(id) }
    end

    def renew_all_loans
      renew_multiple_loans(loans.map(&:loan_id))
    end

    def requests
      @requests ||= requests!
    end

    def requests!
      self.class.get_requests({user_id:self.alma_id})
    end
  end
end