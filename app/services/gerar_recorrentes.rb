class GerarRecorrentes
  include Service

  attr_accessor :mes, :conta

  def run
    @calendar = Calendar.new(date: mes)

    @registros = Registro.where(data: @calendar.range)

    Registro.transaction do

      duplicar_registros_mensais
      duplicar_registros_parcelas

      duplicar_transferencias_mensais
      duplicar_transferencias_parcelas

    end

  end

  def duplicar_registros_mensais

    @registros.efetivos.mensais.no_next.each do |reg|

      new_reg = reg.dup
      new_reg.data = reg.data.next_month
      new_reg.pago = false

      new_reg.save!
      reg.update_columns(next_id: new_reg.id)
    end

  end

  def duplicar_registros_parcelas

    @registros.efetivos.parcelas.no_next.each do |reg|
      next unless reg.parcela < reg.parcelas

      new_reg = reg.dup
      new_reg.data = reg.data.next_month
      new_reg.pago = false

      new_reg.parcela = reg.parcela + 1

      new_reg.save!
      reg.update_columns(next_id: new_reg.id)
    end

  end

  def duplicar_transferencias_mensais

    @registros.transferencias.debitos.mensais.no_next.each do |reg|
      Transferencia.find(reg.id).duplicate
    end

  end

  def duplicar_transferencias_parcelas

    @registros.transferencias.debitos.parcelas.no_next.each do |reg|
      Transferencia.find(reg.id).duplicate
    end

  end

end
