class GerarRecorrentes
  include Service

  attr_accessor :mes, :conta

  def run
    @calendar = Calendar.new(date: mes)

    @registros = Registro.da_conta(conta).where(data: @calendar.range)

    Registro.transaction do

      duplicar_registros_mensais
      duplicar_registros_parcelas

      duplicar_transferencias_mensais
      duplicar_transferencias_parcelas

    end


  end

  def duplicar_registros_mensais

    @registros.efetivos.mensais.each do |reg|

      new_reg = reg.dup
      new_reg.data = reg.data.next_month
      new_reg.pago = false
      new_reg.parent_id = reg.parent_id || reg.id

      new_reg.save!
    end

  end

  def duplicar_registros_parcelas

    @registros.efetivos.parcelas.each do |reg|
      next unless reg.parcela < reg.parcelas

      new_reg = reg.dup
      new_reg.data = reg.data.next_month
      new_reg.pago = false
      new_reg.parent_id = reg.parent_id || reg.id

      new_reg.parcela = reg.parcela + 1

      new_reg.save!
    end

  end

  def duplicar_transferencias_mensais

    @registros.transferencias.debitos.mensais.each do |reg|
      Transferencia.find(reg.id).duplicate
    end

  end

  def duplicar_transferencias_parcelas

    @registros.transferencias.debitos.parcelas.each do |reg|
      Transferencia.find(reg.id).duplicate
    end

  end

end
