class CreateCongressSessions < ActiveRecord::Migration
  def change
    create_table :congress_sessions do |t|
      t.date :date
      t.string :type
    end
  end
end
