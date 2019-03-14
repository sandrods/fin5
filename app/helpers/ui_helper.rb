module UiHelper

  def page_header(title, sub = nil, back_to: nil, &block)
    _sub = sub ? "&nbsp;<small>#{sub}</small>" : ""

    actions = ''
    actions << link_to_back(back_to) if back_to.present?
    actions << capture(&block) if block_given?

    header = <<-HTML
      <div class="page-header">
          <h1>#{title} #{_sub}</h1>
          <div class="actions">#{actions}</div>
      </div>
      #{flash_messages}
    HTML
    header.html_safe
  end

  def flash_messages(dismissable: true)
    _flashes = ""
    flash.each do |name, msg|
      case name.to_sym
        when :notice, :success
          _type = 'success'
        when :danger, :error, :alert
          _type = 'danger'
        when :warning
          _type = 'warning'
        when :info
          _type = 'info'
        else
          _type = name
        end
      _flashes << alert(text: msg, type: _type, dismissable: dismissable)
    end
    flash.discard

    <<-HTML.html_safe
      <div class="flash-messages w-100">
        #{_flashes}
      </div>
    HTML

  end

  def alert(text:, type:, icon: nil, dismissable: false, &block)
    txt = Array(text).join("<br/>").html_safe

    case type.to_s
    when 'success', 'notice'
      _icon = icon(:check_circle_2x)
      clazz = 'success'

    when 'warning'
      _icon = icon(:exclamation_circle_2x)
      clazz = 'warning'

    when 'error', 'danger'
      _icon = icon(:times_circle_2x)
      clazz = 'danger'

    when 'info'
      _icon = icon(:info_circle_2x)
      clazz = 'info'

    else
      _icon = icon(:times_2x)
      clazz = 'dark'

      txt += "<br><small>Invalid type: <b>#{type}</b> for alert</small>".html_safe
    end

    ic = icon.present? ? icon("#{icon}_2x") : _icon

    content = tag.div(ic + tag.div(txt, class: 'text'), class: 'd-flex align-items-center')

    if block_given?
      content += tag.div(&block)
      tag.div content, class: "alert alert-#{clazz} d-flex justify-content-between"

    elsif dismissable
      d = tag.button '&times;'.html_safe, class: 'close', data: { dismiss: 'alert' }, 'aria-hidden': true
      tag.div d + content, class: "alert alert-#{clazz} alert-dismissable"

    else
      tag.div content, class: "alert alert-#{clazz}"

    end

  end

  def icon(_icon, text = nil, left = true)
    ic = fa(_icon)
    if text
      if left
        ic += ('&nbsp;&nbsp;'.html_safe + text.html_safe)
      else
        ic = (text.html_safe + '&nbsp;&nbsp;'.html_safe + ic)
      end
    end
    raw(ic)
  end

  def fa(*names)
    names.map! { |name| name.to_s.gsub('_','-') }
    names.map! do |n|
      return n if n =~ /pull-(?:left|right)/

      cls = []

      if n =~ /^r-(.*)/
        cls << 'far'
        n = $1
      else
        cls << 'fas'
      end

      if n =~ /(.*)-(xs|sm|lg|\dx)$/
        cls << "fa-#{$2}"
        n = $1
      end

      if n =~ /(.*)-spin\b(.*)/
        cls << "fa-spin"
        n = $1
      end

      cls << "fa-#{n}"

      cls.join " "

    end

    tag.i class: names
  end

  def link_to_back(path = nil)
    link_to icon(:arrow_left, "Voltar"), (path || :back), class: 'btn btn-clean py-0'
  end

  def modal(id:, size: nil, center: false, &block)
    content = tag.div(class: 'modal-content', &block)

    _size   = size.present? ? "modal-#{size}" : ''
    _center = center ? 'modal-dialog-centered' : ''

    modal = <<-HTML
      <div class="modal fade" id=#{id}>
        <div class="modal-dialog #{_size} #{_center}" role="document">
          #{content}
        </div>
      </div>
    HTML

    modal.html_safe
  end

  def modal_header(title, sub = nil, &block)
    _sub = sub ? "&nbsp;<small>#{sub}</small>" : ""
    actions = tag.div(class: 'actions', &block) if block_given?

    header = <<-HTML

    <div class="modal-header align-items-center">
      <h1 class="flex-grow-1">#{title} #{_sub}</h1>
      #{actions}

      <button type="button" class="close" data-dismiss="modal" aria-label="Close">
        <span aria-hidden="true">&times;</span>
      </button>
    </div>

      #{flash_messages(dismissable: false)}

    HTML
    header.html_safe
  end


  def card_item(text, label, show_empty = true)
    return unless text.present? || show_empty

    <<-HTML.html_safe
      <label>#{label}</label>
      <p>#{text}</p>
    HTML
  end

  def card_item_block(label, show_empty = true, &block)
    text = capture(&block)
    return unless text.present? || show_empty

    <<-HTML.html_safe
      <label>#{label}</label>
      <p>#{text}</p>
    HTML
  end

  def index_count(count, text)

    _count = tag.span count, class: 'badge badge-info'
    _text  = tag.small text
    _space = "&nbsp;".html_safe

    tag.hr +
    tag.h5(_count + _space + _text, class: 'index_count')

  end

  def dropdown_button(text, variant:'primary', size: '', itens: nil, &block)

    id = 'dd_' + strip_tags(text).parameterize

    if block_given?
      links = tag.div(class: 'dropdown-menu', 'aria-labelledby': id, &block)
    else
      links = tag.div(itens.html_safe, class: 'dropdown-menu', 'aria-labelledby': id)
    end

    button = button_tag text,
                        type: :button,
                        class: "btn btn-#{variant.to_s} btn-#{size} dropdown-toggle",
                        data: { toggle: 'dropdown' },
                        id: id,
                        'aria-haspopup': true,
                        'aria-expanded': false

    tag.div(class: 'btn-group', role: 'group') { button + links }

  end

  def commit_sha
    hash = File.read('COMMIT_SHA') rescue "sha"
    tag.div hash, class: 'sha'
  end

  def link_to_delete(path)

    link_to icon(:trash),
            path,
            method: :delete,
            data: { confirm: "Confirma Exclusão?" },
            class: 'muted-danger'
  end

  def curr(number, show_prefix = false)
    if show_prefix
      number_to_currency(number)
    else
      number_to_currency(number, unit: '')
    end
  end

end
