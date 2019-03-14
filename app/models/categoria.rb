class Categoria < ActiveRecord::Base

  VENDAS = 2
  COMPRAS = 4

  scope :por_cd, ->(cd) { where(cd: cd) }

  def self.to_select
    self.order(:nome).pluck(:nome, :id)
  end
end
