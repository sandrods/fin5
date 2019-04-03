class RegistroPgComponent
  include ViewComponent

  def initialize(registro)
    @registro = registro
  end

  def render
    if @registro.pago?
      span :check_circle_lg, "text-success"
    else
      span :minus_circle_lg, "text-very-muted"
    end
  end

  private

  def span(icn, cls)
    tag.span icon(icn),
              class: "#{cls}",
              data: {
                behavior: 'toggle-pg',
                url: pg_registro_path(@registro)
              }
  end

end
