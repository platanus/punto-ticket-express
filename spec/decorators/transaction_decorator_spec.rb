# coding: utf-8
require 'spec_helper'

describe TransactionDecorator do
  let(:transaction) { Transaction.new.extend TransactionDecorator }
  subject { transaction }
  it { should be_a Transaction }
end
