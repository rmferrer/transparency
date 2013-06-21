class Congressman < ActiveRecord::Base
  attr_accessible :name, :party, :start_date

  has_many :attendances
end
