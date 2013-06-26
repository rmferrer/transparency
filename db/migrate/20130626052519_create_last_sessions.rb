class CreateLastSessions < ActiveRecord::Migration
  def change
    create_table :last_sessions do |t|
      t.date :date
    end
  end
end
