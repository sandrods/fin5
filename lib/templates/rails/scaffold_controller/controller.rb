# coding: UTF-8
class <%= controller_class_name %>Controller < ApplicationController
  before_action :set_<%= singular_table_name %>, only: [:show, :edit, :update, :destroy]

  def index
    @search = <%= class_name %>.search(params[:q])
    @<%= plural_table_name %> = @search.result.order(:<%= attributes_names.first || 'nome' %>)
  end

  def show
  end

  def new
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>
  end

  def edit
  end

  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "#{singular_table_name}_params") %>

    if @<%= orm_instance.save %>
      redirect_to <%= plural_table_name %>_path, notice: <%= "'#{human_name} criado com sucesso.'" %>
    else
      render action: 'new'
    end
  end

  def update
    if @<%= orm_instance.update("#{singular_table_name}_params") %>
      redirect_to <%= plural_table_name %>_path, notice: <%= "'#{human_name} atualizado com sucesso.'" %>
    else
      render action: 'edit'
    end
  end

  def destroy
    @<%= orm_instance.destroy %>
    redirect_to <%= index_helper %>_path, notice: <%= "'#{human_name} apagado com sucesso.'" %>
  end

  private
    def set_<%= singular_table_name %>
      @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    end

    def <%= "#{singular_table_name}_params" %>
      <%- if attributes_names.empty? -%>
      params.require(<%= ":#{singular_table_name}" %>).permit()
      <%- else -%>
      params.require(<%= ":#{singular_table_name}" %>).permit(<%= attributes_names.map { |name| ":#{name}" }.join(', ') %>)
      <%- end -%>
    end
end