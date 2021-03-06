# frozen_string_literal: true

class AddSomeInfoToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :name, :string
    add_column :users, :image, :string
  end
end
