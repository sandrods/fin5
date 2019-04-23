class Diario

  attr_accessor :calendar, :conta_id, :conta, :registros

  def initialize(data, conta_id)
    @calendar = Calendar.new(date: data)

    @conta = conta_id.present? ? Conta.find(conta_id) : contas.first

    da_conta = Registro.da_conta(@conta.id)

    @registros  = da_conta.where(data: @calendar.range)
    @anteriores = da_conta.where("data < ?", @calendar.range.begin)
  end

  def a_pagar
    @anteriores.a_pagar
  end

  def a_pagar_total
    a_pagar.sum(:valor)
  end

  def a_receber
    @anteriores.a_receber
  end

  def a_receber_total
    a_receber.sum(:valor)
  end

  def saldo_inicial
    @saldo_inicial ||= begin
      @anteriores.creditos.pagos.sum(:valor) - @anteriores.debitos.pagos.sum(:valor)
    end
  end

  def saldo
    @saldo ||= begin
      r = @conta.registros.where('data <= ?', @calendar.range.last)
      r.creditos.pagos.sum(:valor) - r.debitos.pagos.sum(:valor)
    end
  end

  def saldo_do_mes
    @saldo_do_mes ||= begin
      total_receitas - total_despesas
    end
  end

  def saldos

    registros = @registros.group_by(&:data)

    saldos = {}
    saldo_atual = saldo_inicial

    @calendar.range.each do |dia|
      saldo_do_dia = registros[dia].to_a.sum(&:valor_cd)
      saldo_atual += saldo_do_dia
      saldos[dia.to_s(:db)] = saldo_atual
    end

    saldos

  end

  def despesas
    @registros.debitos.group(:categoria).sum(:valor)
  end

  def total_despesas
    @registros.debitos.sum(:valor)
  end

  def receitas
    @registros.creditos.group(:categoria).sum(:valor)
  end

  def total_receitas
    @registros.creditos.sum(:valor)
  end

  def saldo_final
    @saldo_final ||= saldo_do_mes + saldo_inicial
  end

  def contas
    Registro.select(:conta_id)
            .where.not(conta_id: nil)
            .where(data: @calendar.range)
            .order(:conta_id)
            .distinct.map { |r| Conta.find r.conta_id }
  end

end
