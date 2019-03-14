document.addEventListener "turbolinks:before-cache", ->
  $('select').not('.custom_select').select2 "destroy"

$(document).on "hidden.bs.modal", "#global_modal", (e) ->
    $(e.target).removeData("bs.modal").find(".modal-content").empty()

$(document).on "click", '[data-behavior~=load-modal]', (ev) ->
    ev.preventDefault()
    url = this.getAttribute('href') || this.getAttribute('data-url')

    if size = this.getAttribute('data-modal-size')
      $("#global_modal .modal-dialog").addClass("modal-#{size}")

    $("#global_modal .modal-content").load url, App.modals

    $('#global_modal').modal('show')


window.App ||= {}

App.init = ->

  $.ajaxSetup headers: { 'X-CSRF-Token': Rails.csrfToken() }

  $('[data-toggle="tooltip"]').tooltip()

  $(".datepicker").each () ->

    $(this).flatpickr
      dateFormat: 'd/m/Y'
      locale: 'pt'
      minDate: this.getAttribute('data-min-date') # uma data no mesmo formato ou :today
      maxDate: this.getAttribute('data-max-date')

  $("[data-mask]").each () ->
    _mask = this.getAttribute('data-mask')

    $(this).mask _mask, autoclear: false

  $(".currency").maskMoney()

  $("input[type=checkbox].pago").bootstrapToggle
    on: 'PAGO'
    off: 'NÃO PAGO'
    width: '120px'

  $("input[type=checkbox].cd").bootstrapToggle
    on: 'CRÉDITO'
    off: 'DÉBITO'
    width: '120px'

  $('.simple_form .clear').on 'click', (e) ->
    e.preventDefault()

    for input in $('.simple_form input[type=text]')
      $(input).val('')

    for input in $('.simple_form input[type=checkbox]')
      $(input).prop('checked', false)

    for select_found in $('.simple_form select')
      $(select_found).not('.custom_select').val(null).trigger("change")

    for select_found in $('.custom_select')
      $(select_found).val([])

  App.select2.init()

App.modals = ->
  App.init()
  # App.dependentes.init()
  # adicione aqui codigo para ser executado em modais

document.addEventListener "turbolinks:load", ->
  App.init()


# rodar js baseado em controller#action
# exemplo: return unless in_action('login#index')
window.in_action = (act) ->
  $('[data-action]').first().data('action') == act
