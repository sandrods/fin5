class Registros::TransferenciasController < ApplicationController

  def new
    @transf = Transferencia.new
    render layout: false
  end

  def create
    @transf = Transferencia.new transf_params

    if @transf.create
    else
      flash[:error] = "Não foi possível salvar transferência: #{@transf.errors.full_messages}"
    end

    redirect_to financeiro_diario_path(mes: @transf.data)
  end

  def edit
    @transf = Transferencia.find params[:id]
    render layout: false
  end

  def update
    @transf = Transferencia.find params[:id]

    if @transf.update transf_params
    else
      flash[:error] = "Não foi possível salvar transferência: #{@transf.errors.full_messages}"
    end

    redirect_to financeiro_diario_path(mes: @transf.data)
  end

  def destroy
    @transf = Transferencia.find params[:id]

    @transf.destroy

    redirect_to financeiro_diario_path(mes: @transf.data)
  end

 private

  def transf_params
    params.require(:transferencia)
          .permit(:data, :valor, :conta_origem, :conta_destino, :descricao)
          .delocalize(data: :date, valor: :number)
  end

end
