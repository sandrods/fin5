module Service
  extend ActiveSupport::Concern
  include ActiveModel::Model

  def initialize(form_attrs, **key_args)
    super({}.merge(key_args).merge(form_attrs))
  end

  class_methods do

    def run(form_attrs, **key_args)
      service = new(form_attrs, **key_args)
      service.run if service.valid?
      service

    rescue Error => e
      return service
    end

    def run!(form_attrs, **key_args)
      service = new(form_attrs, **key_args)
      if service.valid?
        service.run
      else
        raise Error.new(service)
      end
    end

  end

  def fail!(msg, field = :base)
    errors.add field, msg
    raise Error.new(self)
  end

  def add_error(msg, field = :base)
    errors.add field, msg
  end

  def success?
    errors.empty?
  end

  def error_messages(sentence: false)
    if sentence
      errors.full_messages.to_sentence
    else
      errors.full_messages.join('<br/>')
    end
  end

  def warning?
    !warnings.empty?
  end

  def warnings
    @warnings ||= ActiveModel::Errors.new(self)
  end

  def info?
    !infos.empty?
  end

  def infos
    @infos ||= ActiveModel::Errors.new(self)
  end

  def logger
    Rails.logger
  end

  class Error < StandardError

    attr_accessor :service

    def initialize(_service)
      @service = _service
      super(_service.error_messages)
    end

  end

  private

  def msgs from:, html: false
    return unless from.present?

    if html
      from.join("<br/>").html_safe
    else
      from.join("\n")
    end
  end

end
