document.addEventListener "turbolinks:before-cache", ->
  for select in $('select')
    if $(select).hasClass("select2-hidden-accessible")
      $(select).select2 "destroy"

App.select2 ||= {}

App.select2.init = ->

  $('select').not('.custom_select').not('.select2_ajax').not('.search select').select2
    placeholder: 'Selecione'
    allowClear: true
    theme: "bootstrap"

  $('.search select').not('.custom_select').select2
    placeholder: 'Selecione'
    allowClear: true

  for select_found in $('.select2_ajax')
    App.select2.ajax($(select_found))

  for select_found in $('[data-sel2]')
    sel = $(select_found)
    if sel.data('sel2').id
      opt = new Option(sel.data('sel2').text, sel.data('sel2').id, true, true)
      sel.append(opt).trigger('change')

App.select2.ajax = (el) ->
  c = Object.assign {}, App.select2.ajax_configs # dup

  if el.data('parent-modal')
    c.dropdownParent = $(el.data('parent-modal'))

  el.select2 c

App.select2.ajax_configs =

  placeholder: "Digite o texto"
  language: 'pt-BR'
  allowClear: true
  theme: "bootstrap"
  minimumInputLength: 2
  width: '100%'
  ajax:
    dataType: 'json'
    delay: 250
    cache: true
    processResults: (data, params) -> { results: data.items }

  escapeMarkup: (markup) -> markup

  templateResult: (item)  ->
    if item.sub?
      "#{item.text}<span class='select2-sub'>#{item.sub}</span>"
    else
      "#{item.text}"

  templateSelection: (item) ->
    if item.sub?
      "<b>#{item.text}</b> &nbsp; <small style='color: #888'>#{item.sub}</small>"
    else
      "#{item.text}"
