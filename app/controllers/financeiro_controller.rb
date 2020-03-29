class FinanceiroController < ApplicationController

  def diario
    session[:mes] = params[:mes] if params[:mes]
    session[:conta] = params[:conta] if params[:conta]

    @diario = Diario.new(session[:mes], session[:conta])
  end

  def anual
    @anual = Anual.new(params[:ano])
  end

end
