class ContasController < ApplicationController
  before_action :set_conta, only: [:show, :edit, :update, :destroy]

  def index
    @contas = Conta.order(:nome)
  end

  def new
    @conta = Conta.new
  end

  def edit
  end

  def create
    @conta = Conta.new(conta_params)

    if @conta.save
      redirect_to contas_path, notice: 'Conta criada com sucesso.'
    else
      render action: 'new'
    end
  end

  def update
    if @conta.update(conta_params)
      redirect_to contas_path, notice: 'Conta atualizada com sucesso.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @conta.destroy
    redirect_to contas_path, notice: 'Conta apagada com sucesso.'
  end

  private
    def set_conta
      @conta = Conta.find(params[:id])
    end

    def conta_params
      params.require(:conta).permit(:nome)
    end
end
