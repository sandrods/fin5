class Diario

  attr_accessor :calendar, :contas

  def initialize(data)
    @calendar = Calendar.new(date: data)
    @contas = ::Conta.order(:id).map { |c| Conta.new(c, @calendar.range) }.select { |c| c.registros.present? }
    @registros = Registro.where(data: @calendar.range)
  end

  def a_pagar
    @registros.a_pagar
  end

  def a_pagar_total
    a_pagar.sum(:valor)
  end

  def a_receber
    @registros.a_receber
  end

  def a_receber_total
    a_receber.sum(:valor)
  end

  def saldo_inicial
    @saldo_inicial ||= begin
      ant = Registro.where('data < ?', @calendar.range.begin)
      ant.creditos.sum(:valor) - ant.debitos.sum(:valor)
    end
  end

  def saldo_final
    @saldo_final ||= begin
      ant = Registro.where('data <= ?', @calendar.range.last)
      ant.creditos.sum(:valor) - ant.debitos.sum(:valor)
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
    @registros.debitos.efetivos.group(:categoria).sum(:valor)
  end

  def total_despesas
    @registros.debitos.efetivos.sum(:valor)
  end

  def receitas
    @registros.creditos.efetivos.group(:categoria).sum(:valor)
  end

  def total_receitas
    @registros.creditos.efetivos.sum(:valor)
  end

  class Conta

    def initialize(conta, range)
      @range = range
      @conta = conta
    end

    delegate :nome, to: :@conta

    def registros
      @conta.registros.where(data: @range).order(data: :desc)
    end

    def saldo_inicial
      r = @conta.registros.where('data < ?', @range.begin)
      r.creditos.pagos.sum(:valor) - r.debitos.pagos.sum(:valor)
    end

    def saldo
      r = @conta.registros.where('data <= ?', @range.last)
      r.creditos.pagos.sum(:valor) - r.debitos.pagos.sum(:valor)
    end

    def saldo_do_mes
      r = @conta.registros.where(data: @range)
      r.creditos.sum(:valor) - r.debitos.sum(:valor)
    end

  end


end
