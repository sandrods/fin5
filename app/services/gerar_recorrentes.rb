class GerarRecorrentes
  include Service

  attr_accessor :mes, :conta

  def run
    @calendar = Calendar.new(date: mes).last_calendar

    regs = Registro.da_conta(conta).where(data: @calendar.range, transf_id: nil)

    regs.where(recorrencia: 'M').each do |reg|

      new_reg = reg.dup
      new_reg.data = reg.data.next_month
      new_reg.pago = false
      new_reg.parent_id = reg.parent_id || reg.id

      new_reg.save!
    end

    regs.where(recorrencia: 'P').each do |reg|
      next unless reg.parcela < reg.parcelas

      new_reg = reg.dup
      new_reg.data = reg.data.next_month
      new_reg.pago = false
      new_reg.parent_id = reg.parent_id || reg.id

      new_reg.parcela = reg.parcela + 1

      new_reg.save!
    end

  end
end
