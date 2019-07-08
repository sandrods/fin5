class RegistrosController < ApplicationController

  def index
    params[:q] = { data_gteq: 30.days.ago.to_date } unless params[:q]
    @search = Registro.order('data desc').search(params[:q])
  end

  def new
    @registro = Registro.new(cd: params[:cd], conta_id: params[:conta_id])
    render layout: false
  end

  def create
    @registro = Registro.new registro_params
    if @registro.save
    else
      flash[:error] = "Não foi possível salvar registro: #{@registro.errors.full_messages}"
    end

    redirect_to financeiro_diario_path(mes: @registro.data)
  end

  def edit
    @registro = Registro.find params[:id]

    redirect_to edit_transferencia_path(@registro) and return if @registro.transferencia?

    render layout: false
  end

  def update
    @registro = Registro.find params[:id]

    params[:registro][:cd] = helpers.bool2cd(registro_params[:cd])

    if @registro.update registro_params
    else
      flash[:error] = "Não foi possível salvar registro: #{@registro.errors.full_messages}"
    end

    redirect_to financeiro_diario_path(mes: @registro.data)
  end

  def destroy
    @registro = Registro.find params[:id]

    @registro.destroy!

    redirect_to financeiro_diario_path(mes: @registro.data)
  end

  def duplicate
    @registro = Registro.find params[:id]

    new_reg = @registro.duplicate!

    redirect_to financeiro_diario_path(mes: new_reg.data)
  end

  def pg
    @registro = Registro.find params[:id]
    pg = !@registro.pago
    @registro.update! pago: pg
    @registro.transferencia.update!(pago: pg) if @registro.transferencia?

    render partial: "financeiro/diario/conta", object: Diario.new(session[:mes], session[:conta]), as: :diario
  end

  def recorrentes
    service = GerarRecorrentes.run(mes: params[:mes], conta: params[:conta])

    if service.success?
      flash[:notice] = "Registros recorrentes gerados com sucesso"
      month = Calendar.new(date: params[:mes]).next_month
    else
      flash[:error] = service.error_messages
      month = params[:mes]
    end

    redirect_to financeiro_diario_path(mes: month, conta: params[:conta])
  end

  private

   def registro_params
     params.require(:registro)
           .permit(:data, :valor, :conta_id, :forma_id, :descricao, :pago, :cd, :categoria_id, :colecao_id, :recorrencia, :parcela, :parcelas)
           .delocalize(data: :date, valor: :number)
   end

end
