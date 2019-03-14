# coding: UTF-8
class CategoriasController < ApplicationController
  before_action :set_categoria, only: [:show, :edit, :update, :destroy]

  def index
    @search = Categoria.search(params[:q])
    @categorias = @search.result.order(:nome)
  end

  def show
  end

  def new
    @categoria = Categoria.new
  end

  def edit
  end

  def create
    @categoria = Categoria.new(categoria_params)

    if @categoria.save
      redirect_to categorias_path, notice: 'Categoria criado com sucesso.'
    else
      render action: 'new'
    end
  end

  def update
    if @categoria.update(categoria_params)
      redirect_to categorias_path, notice: 'Categoria atualizado com sucesso.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @categoria.destroy
    redirect_to categorias_path, notice: 'Categoria apagado com sucesso.'
  end

  private
    def set_categoria
      @categoria = Categoria.find(params[:id])
    end

    def categoria_params
      params.require(:categoria).permit(:nome, :cd)
    end
end
