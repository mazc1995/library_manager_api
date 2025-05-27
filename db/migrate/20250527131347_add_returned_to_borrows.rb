class AddReturnedToBorrows < ActiveRecord::Migration[8.0]
  def change
    add_column :borrows, :returned, :boolean, default: false
    add_column :borrows, :returned_date, :datetime
  end
end
