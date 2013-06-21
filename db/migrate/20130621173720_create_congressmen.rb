class CreateCongressmen < ActiveRecord::Migration
  def change
    create_table :congressmen do |t|
      t.string :name
      t.string :party
      t.date :start_date
    end
  end
end
