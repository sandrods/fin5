class Transferencia
  include ActiveModel::Model
  attr_accessor :conta_origem, :conta_destino, :data, :valor, :reg_origem, :reg_destino, :descricao

  validates :conta_origem, :conta_destino, :data, :valor, presence: true, on: :create
  validates :data, :valor, presence: true, on: :update

  def self.find(id)

    r1 = Registro.find id
    r2 = Registro.find r1.transf_id

    params = {}

    if r1.despesa?
      params[:reg_origem] = r1
      params[:reg_destino] = r2
    else
      params[:reg_origem] = r2
      params[:reg_destino] = r1
    end

    params[:data] = r1.data
    params[:valor] = r1.valor
    params[:descricao] = r1.descricao

    new(params)

  end

  def create
    return false unless valid?(:create)

    origem = Conta.find @conta_origem
    destino = Conta.find @conta_destino

    Conta.transaction do

      o = origem.registros.create!  data: @data,
                                    descricao: @descricao,
                                    valor: @valor,
                                    cd: "D",
                                    pago: true

      d = destino.registros.create! data: @data,
                                    descricao: @descricao,
                                    valor: @valor,
                                    cd: "C",
                                    transf_id: o.id,
                                    pago: true

      o.update_columns transf_id: d.id

    end

  end

  def update params

    @valor = params[:valor]
    @data = params[:data]
    @descricao = params[:descricao]

    return false unless valid?(:update)

    attrs = {
      valor: @valor,
      data: @data,
      descricao: @descricao
    }

    Registro.transaction do
      @reg_origem.update! attrs
      @reg_destino.update! attrs
    end

  end

  def destroy

    Registro.transaction do
      @reg_origem.destroy!
      @reg_destino.destroy!
    end

  end

  def to_param
    persisted? ? @reg_origem.id.to_s : nil
  end

  def persisted?
    @reg_origem.present?
  end

end
