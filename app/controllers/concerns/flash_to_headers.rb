# coding: UTF-8

module FlashToHeaders
  extend ActiveSupport::Concern

  included do
    after_action :flash_to_headers
  end

  private

  def flash_to_headers
    return unless request.xhr? && flash_message.present?

    fm = flash_message
          .gsub('á', '&aacute;')
          .gsub('ã', '&atilde;')
          .gsub('Í', '&Iacute;')
          .gsub('í', '&iacute;')
          .gsub('ó', '&oacute;')
          .gsub('ê', '&ecirc;')
          .gsub('ç', '&ccedil;')
          .gsub('õ', '&otilde;')
          .gsub('ô', '&ocirc;')

    response.headers['X-Message'] = fm
    response.headers["X-Message-Type"] = flash_type.to_s

    #flash.discard # don't want the flash to appear when you reload page
  end

  def flash_message
    [:error, :warning, :notice].each do |type|
      return flash[type] unless flash[type].blank?
    end
    nil
  end

  def flash_type
    [:error, :warning, :notice].each do |type|
      return type unless flash[type].blank?
    end
  end

end
