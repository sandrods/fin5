class AddCompetenciaToRegistros < ActiveRecord::Migration[5.2]
  def change
    add_column :registros, :competencia, :date
  end
end
