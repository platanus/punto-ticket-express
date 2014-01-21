module PTE
  class Cron
    # Changes payment_status from processing to inactive for transactions
    # that have been processing status for 15 minutes or more
    def self.deactivate_old_pending_transactions
      transactions = Transaction.processing.more_than_x_minutes_old(15)
      transactions.each { |transaction| transaction.save_inactive_status }
    end

    def self.clean_old_participant_files
      PTE::Event::Xls.clean_old_participant_files
    end
  end
end
