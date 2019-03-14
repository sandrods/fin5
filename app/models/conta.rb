class Conta < ActiveRecord::Base

  validates_length_of :nome, maximum: 20

  has_many :registros

  def Conta.to_select
    @@combo ||= Conta.update_select
  end

  def Conta.update_select
    @@combo = Conta.all.map {|c| [c.nome, c.id]}
  end

  def saldo
    registros.creditos.pagos.sum(:valor) - registros.debitos.pagos.sum(:valor)
  end

end
