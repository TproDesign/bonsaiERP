# encoding: utf-8
# Creates a devolution that updates the Income#total and creates an
# instance of AccountLedger with the devolution data
class Incomes::Devolution < Devolution

  # Validations
  validates_presence_of :income

  # Updates Income#total and creates and AccountLedger object with the
  # devolution data
  def pay_back
    return false unless valid?

    commit_or_rollback do
      res = save_income
      res = create_ledger

      set_errors(income, ledger) unless res

      res
    end
  end

  def income
    @income ||= Income.active.where(id: account_id).first
  end
  alias :transaction :income

private
  def save_income
    update_transaction
    err = Incomes::Errors.new(income)
    err.set_errors

    income.save
  end

  def create_ledger
    @ledger = build_ledger(
      amount: -amount, operation: 'devin', account_id: income.id,
      status: get_status
    )
    @ledger.save_ledger
  end
end