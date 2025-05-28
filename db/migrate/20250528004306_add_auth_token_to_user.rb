class AddAuthTokenToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :auth_token, :string
    
    add_index :users, :auth_token, unique: true
    add_index :users, :email, unique: true
  end
end
