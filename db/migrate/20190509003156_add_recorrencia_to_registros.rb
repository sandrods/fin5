class AddRecorrenciaToRegistros < ActiveRecord::Migration[5.2]
  def change
    add_column :registros, :parcelas, :integer
    add_column :registros, :parcela, :integer
    add_column :registros, :parent_id, :integer
    add_column :registros, :recorrencia, :string
  end
end
