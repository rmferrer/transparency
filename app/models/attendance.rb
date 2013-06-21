class Attendance < ActiveRecord::Base
  attr_accessible :status

  belongs_to :congressman
  belongs_to :congress_session
end
