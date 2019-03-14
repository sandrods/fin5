class FinanceiroController < ApplicationController

  def diario
    @diario = Diario.new(params[:mes])
  end

  def anual
    @anual = Anual.new(params[:ano])
  end

end
