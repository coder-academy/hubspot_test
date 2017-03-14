class AddVidToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :vid, :string
  end
end
