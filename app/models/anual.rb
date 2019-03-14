class Anual

  attr_accessor :calendar

  def initialize(ano)
    @calendar = Calendar.new(year: ano || Date.today.year)
    @registros = Registro.where(data: @calendar.range)
  end

  def saldos

    anteriores = Registro.where('data < ?', @calendar.range.begin).efetivos
    saldo_inicial = anteriores.creditos.sum(:valor) - anteriores.debitos.sum(:valor)

    registros = @registros.group_by { |r| r.data.month }

    saldos = {}
    saldo_atual = saldo_inicial

    (1..12).each do |mes|
      saldo_do_mes = registros[mes].to_a.sum(&:valor_cd)
      saldo_atual += saldo_do_mes
      saldos[local_month(mes)] = saldo_atual
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

  def saldo_inicial
    @saldo_inicial ||= begin
      ant = Registro.where('data < ?', @calendar.range.begin).efetivos
      ant.creditos.sum(:valor) - ant.debitos.sum(:valor)
    end
  end

  def saldo_final
    @saldo_final ||= begin
      ant = Registro.where('data <= ?', @calendar.range.last).efetivos
      ant.creditos.sum(:valor) - ant.debitos.sum(:valor)
    end
  end

  private

  def local_month(month)
    #I18n.t("date.month_names")[month] # "December"
    #I18n.t("date.abbr_month_names")[month] # "Dec"
    Date.new(@calendar.year, month, 1).to_s(:db)
  end

end
