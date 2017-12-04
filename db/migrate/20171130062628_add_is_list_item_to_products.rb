class AddIsListItemToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :is_list_item, :boolean, default: false
  end
end
