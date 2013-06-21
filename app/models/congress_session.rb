class CongressSession < ActiveRecord::Base
  attr_accessible :date, :type

  has_many :attendances
end
