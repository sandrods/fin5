class FinanceiroController < ApplicationController

  def diario
    @diario = Diario.new(params[:mes], params[:conta])
  end

  def anual
    @anual = Anual.new(params[:ano])
  end

end
