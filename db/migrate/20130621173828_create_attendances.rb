class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.string :status
      t.integer :congressman_id
      t.integer :congress_session_id
    end
  end
end
