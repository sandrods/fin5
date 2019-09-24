class AddNextToRegistros < ActiveRecord::Migration[5.2]
  def change
    add_column :registros, :next_id, :integer, index: true
  end
end
