class Transferencia
  include ActiveModel::Model

  attr_accessor *%i(
    conta_origem
    conta_destino
    data
    valor
    origem
    destino
    descricao
    recorrencia
    parcela
    parcelas
    parent
  )

  validates :conta_origem, :conta_destino, :data, :valor, presence: true

  def self.find(id)

    r1 = Registro.find id
    r2 = Registro.find r1.transf_id

    params = {}

    if r1.despesa?
      params[:origem] = r1
      params[:destino] = r2
    else
      params[:origem] = r2
      params[:destino] = r1
    end

    params[:conta_origem]  = params[:origem].conta_id
    params[:conta_destino] = params[:destino].conta_id

    params[:data]        = r1.data
    params[:valor]       = r1.valor
    params[:descricao]   = r1.descricao
    params[:recorrencia] = r1.recorrencia
    params[:parcela]     = r1.parcela
    params[:parcelas]    = r1.parcelas

    new(params)

  end

  def create
    return false unless valid?

    cta_origem = Conta.find @conta_origem
    cta_destino = Conta.find @conta_destino

    Conta.transaction do

      @origem = cta_origem
                  .registros
                  .create!  data: @data,
                            descricao: @descricao,
                            valor: @valor,
                            cd: "D",
                            pago: false,
                            recorrencia: @recorrencia,
                            parcela: @parcela,
                            parcelas: @parcelas

      @destino = cta_destino
                   .registros
                   .create! data: @data,
                            descricao: @descricao,
                            valor: @valor,
                            cd: "C",
                            transf_id: @origem.id,
                            pago: false,
                            recorrencia: @recorrencia,
                            parcela: @parcela,
                            parcelas: @parcelas

      @origem.update_columns transf_id: @destino.id

    end

    self

  end

  def update params

    @valor         = params[:valor]
    @data          = params[:data]
    @descricao     = params[:descricao]
    @recorrencia   = params[:recorrencia]
    @parcela       = params[:parcela]
    @parcelas      = params[:parcelas]
    @conta_origem  = params[:conta_origem]
    @conta_destino = params[:conta_destino]

    return false unless valid?

    attrs = {
      valor: @valor,
      data: @data,
      descricao: @descricao,
      recorrencia: @recorrencia,
      parcela: @parcela,
      parcelas: @parcelas
    }

    Registro.transaction do
      @origem.update!  attrs.merge(conta_id: @conta_origem)
      @destino.update! attrs.merge(conta_id: @conta_destino)
    end

  end

  def destroy

    Registro.transaction do
      @origem.destroy!
      @destino.destroy!
    end

  end

  def duplicate
    return if @origem.parcela? && @parcela == @parcelas

    attrs = {
      conta_origem:  @origem.conta_id,
      conta_destino: @destino.conta_id,
      valor:         @valor,
      data:          @data.next_month,
      descricao:     @descricao,
      recorrencia:   @recorrencia,
      parcela:       @origem.parcela? ? @parcela + 1 : nil,
      parcelas:      @parcelas
    }

    if new_transf = Transferencia.new(attrs).create
      @origem.update_columns next_id: new_transf.origem.id
      @destino.update_columns next_id: new_transf.destino.id
    end

    new_transf

  end

  def to_param
    persisted? ? @origem.id.to_s : nil
  end

  def persisted?
    @origem.present?
  end

end
