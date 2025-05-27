class CreateBorrows < ActiveRecord::Migration[8.0]
  def change
    create_table :borrows do |t|
      t.datetime :borrow_date
      t.datetime :due_date
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true

      t.timestamps
    end
  end
end
