module ViewComponent
  extend ActiveSupport::Concern

  included do
    attr_accessor :view
  end

  class_methods do

    def render(view, *args, &block)
      c = new(*args)
      c.view = view
      c.render(&block)
    end

  end

  def add(content)
    @result ||= []
    @result << content
  end

  def render_result
    return '' unless @result.present?

    @result.join("\n").html_safe
  end

  def method_missing(method, *args, &block)
    if view.respond_to? method
      view.send method, *args, &block
    else
      super
    end
  end

end
