class GerarRecorrentes
  include Service

  attr_accessor :mes

  def run
    @calendar = Calendar.new(date: mes).last_calendar

    regs = Registro.where(data: @calendar.range, transf_id: nil)

    regs.where(recorrencia: 'M') do |reg|

      new_reg = reg.dup
      new_reg.data = reg.data.next_month
      new_reg.pago = false
      new_reg.parent_id = reg.parent_id || reg.id

      new_reg.save!
    end

    regs.where(recorrencia: 'P') do |reg|
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
