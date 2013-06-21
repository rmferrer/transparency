class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.string :status
    end
  end
end
